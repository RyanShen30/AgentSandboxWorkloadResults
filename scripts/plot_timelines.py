"""Aligned tool/memory/cache figures from existing records; never runs a workload.

Chart contract: relate tool execution intervals to observed memory/cache changes.
Use one latency bar per call, plus memory/cache panels sharing a time axis,
following AgentCgroup figures 5/6. Export PNG/SVG into the existing run folders.
Wall-clock figures retain all samples and scan pauses. A second, explicitly
labelled view removes only pause intervals for display; samples taken inside
those pauses remain visible as grey dots. Neither view reconstructs an
uninstrumented Agent execution. Cache dots are N+1 discrete mincore scans of
host-owned rootfs files, not continuous or guest-wide cache measurements.
Palette: blue/gold plus neutrals; dash, marker and hatch distinguish meanings.
"""
from pathlib import Path
import json

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
from matplotlib.patches import Patch
from matplotlib.ticker import MaxNLocator
import numpy as np

GIB = 1024 ** 3
BLUE = '#3366A3'
GOLD = '#BC8528'
INK = '#29333D'
GRAY = '#6B747D'
PAUSE = '#E6E8EB'


def save_figure(fig, output_stem):
    stem = Path(output_stem)
    fig.savefig(stem.with_suffix('.png'), dpi=150)
    svg = stem.with_suffix('.svg')
    fig.savefig(svg, metadata={'Date': None})
    svg.write_text('\n'.join(line.rstrip() for line in svg.read_text().splitlines()) + '\n')


class Timeline:
    """One recorded monotonic clock, with an optional pause-removal transform."""

    def __init__(self, run, steps, samples, boundaries, waits):
        self.t0 = run['started_ns']
        self.end = run['measurement_finished_ns']
        self.steps = steps
        self.samples = samples
        self.boundaries = boundaries
        self.waits = waits
        self.pauses = [(b['pause_started_ns'], b['resumed_ns']) for b in boundaries]
        assert all(self.t0 <= a < b <= self.end for a, b in self.pauses)
        assert all(a[1] <= b[0] for a, b in zip(self.pauses, self.pauses[1:]))
        for step in steps:
            a, b = step['started_ns'], step['finished_ns']
            assert self.t0 <= a <= b <= self.end
            assert step['controller_started_ns'] <= a <= b <= step['controller_finished_ns']
            assert abs((b - a) / 1e9 - step['tool_seconds']) < 1e-7
            assert not any(a < y and b > x for x, y in self.pauses)
        assert [b['step'] for b in boundaries] == list(range(len(steps) + 1))
        assert all(b['pause_confirmed_ns'] <= b['started_ns'] <= b['finished_ns']
                   <= b['resumed_ns'] for b in boundaries)
        assert all(b['finished_ns'] >= s['finished_ns']
                   for s, b in zip(steps, boundaries[1:]))
        assert all(self.t0 <= m['timestamp_ns'] <= self.end for m in samples)
        assert all(self.t0 <= w['started_ns'] <= w['finished_ns'] <= self.end for w in waits)

    def seconds(self, stamps, compact=False):
        # Subtract the integer clock origin before converting to float.
        elapsed = (np.asarray(stamps, dtype=np.int64) - self.t0) / 1e9
        if not compact:
            return elapsed
        removed = np.zeros_like(elapsed)
        for a, b in self.pauses:
            removed += np.clip(elapsed - (a - self.t0) / 1e9, 0, (b - a) / 1e9)
        return elapsed - removed

    def paused_samples(self):
        stamps = np.asarray([m['timestamp_ns'] for m in self.samples], dtype=np.int64)
        paused = np.zeros(len(stamps), dtype=bool)
        for a, b in self.pauses:
            paused |= (stamps >= a) & (stamps < b)
        return paused

    def validate(self):
        pause_seconds = sum((b - a) / 1e9 for a, b in self.pauses)
        wall_seconds = (self.end - self.t0) / 1e9
        compact_seconds = float(self.seconds(self.end, True))
        assert abs(wall_seconds - pause_seconds - compact_seconds) < 1e-8
        for a, b in self.pauses:
            assert abs(float(self.seconds(a, True) - self.seconds(b, True))) < 1e-8
        starts = self.seconds([s['started_ns'] for s in self.steps], True)
        ends = self.seconds([s['finished_ns'] for s in self.steps], True)
        assert np.allclose(ends - starts, [s['tool_seconds'] for s in self.steps],
                           rtol=0, atol=1e-8)
        samples = self.seconds([m['timestamp_ns'] for m in self.samples], True)
        assert np.all(np.diff(samples) >= -1e-8)
        return {
            'tool_calls': len(self.steps), 'cache_snapshots': len(self.boundaries),
            'continuous_samples': len(self.samples),
            'samples_during_pauses': int(self.paused_samples().sum()),
            'wall_seconds': wall_seconds, 'pause_seconds': pause_seconds,
            'display_seconds_without_pauses': compact_seconds,
            'async_wait_intervals': len(self.waits),
            'checks': {
                'one_clock_and_ordered_intervals': True,
                'tools_do_not_overlap_scan_pauses': True,
                'latency_matches_recorded_interval': True,
                'cache_scans_inside_confirmed_freeze': True,
                'compact_transform_preserves_every_tool_duration': True,
                'compact_transform_removes_only_pause_duration': True,
                'all_memory_samples_retained_in_both_views': True,
                'all_n_plus_one_cache_snapshots_retained': True,
            },
        }


def load_timeline(pack, source_dir):
    _, run, steps, samples, boundaries, _ = pack
    path = Path(source_dir) / 'async-barriers.jsonl'
    waits = [json.loads(line) for line in path.read_text().splitlines() if line.strip()] if path.exists() else []
    return Timeline(run, steps, samples, boundaries, waits)


def _phase_handles(timeline, compact):
    handles = [Patch(facecolor=BLUE, alpha=.16, label='Tool execution interval')]
    if compact:
        handles.append(Line2D([], [], color=GRAY, marker='.', ls='none', ms=5,
                              label='Samples during omitted pauses'))
    else:
        handles.append(Patch(facecolor=PAUSE, edgecolor='#AAB0B7', hatch='///',
                             lw=.3, label='Pause / cache scan'))
    if timeline.waits:
        handles.append(Patch(facecolor=GOLD, alpha=.16, hatch='..',
                             label='Async dependency wait'))
    return handles


def draw_panels(axes, timeline, metrics, compact=False, scale=1, titles=True, annotate=True):
    """Latency uses call index; memory/cache share the same clock transform."""
    x = lambda stamps: timeline.seconds(stamps, compact) / scale
    duration = float(x(timeline.end))
    for ax in axes[1:]:
        ax.set_facecolor('white')
        if not compact:
            for a, b in timeline.pauses:
                ax.axvspan(*x([a, b]), facecolor=PAUSE, alpha=.42,
                           edgecolor='#C4C8CE', hatch='///', linewidth=.15, zorder=0)
        for wait in timeline.waits:
            ax.axvspan(*x([wait['started_ns'], wait['finished_ns']]),
                       facecolor=GOLD, alpha=.13, edgecolor=GOLD,
                       hatch='..', linewidth=.2, zorder=0)
        for step in timeline.steps:
            ax.axvspan(*x([step['started_ns'], step['finished_ns']]),
                       facecolor=BLUE, alpha=.085, edgecolor='none', zorder=0)
        ax.set_xlim(0, duration * 1.004)
        ax.set_ylim(bottom=0)
        ax.grid(axis='y', color='#DCE0E4', lw=.6, zorder=0)
        ax.set_axisbelow(True)
        ax.xaxis.set_major_locator(MaxNLocator(nbins=7))
        ax.yaxis.set_major_locator(MaxNLocator(nbins=5, min_n_ticks=3))
        ax.tick_params(axis='both', labelsize=9)
        ax.ticklabel_format(axis='y', style='plain', useOffset=False)

    steps = timeline.steps
    call_ids = np.asarray([step['step'] for step in steps])
    latencies = np.asarray([step['tool_seconds'] for step in steps])
    ax = axes[0]
    ax.bar(call_ids, latencies, width=.7, color=BLUE,
           label='One bar per tool call', zorder=2)
    errors = np.asarray([step['exit_code'] != 0 for step in steps])
    if errors.any():
        ax.scatter(call_ids[errors], latencies[errors], s=33, facecolor='white',
                   edgecolor=INK, lw=.8, label='Nonzero exit', zorder=4)
    ax.set(xlabel='Tool call index', ylabel='Tool latency (s)',
           xlim=(.4, len(steps) + .6), ylim=(0, max(latencies) * 1.23))
    ax.grid(axis='y', color='#DCE0E4', lw=.6)
    ax.set_axisbelow(True)
    ax.xaxis.set_major_locator(MaxNLocator(integer=True, nbins=10))
    if len(steps) <= 15:
        ax.set_xticks(call_ids)
    ax.yaxis.set_major_locator(MaxNLocator(nbins=5, min_n_ticks=3))
    ax.tick_params(axis='both', labelsize=9)
    if annotate and len(steps) <= 15:
        for index, value in zip(call_ids, latencies):
            label = f'{value:.3f}' if value < 1 else f'{value:.2f}'
            ax.annotate(label, (index, value), xytext=(0, 6),
                        textcoords='offset points', ha='center', fontsize=8, color=INK)
    elif annotate:
        k = int(np.argmax(latencies))
        ax.annotate(f"#{call_ids[k]}  {latencies[k]:.2f} s",
                    (call_ids[k], latencies[k]), xytext=(0, 9),
                    textcoords='offset points', ha='center', fontsize=8, color=INK)
    ax.legend(loc='lower left', bbox_to_anchor=(0, 1.02), ncol=2,
              frameon=False, fontsize=8, borderaxespad=0)

    stamps = [m['timestamp_ns'] for m in timeline.samples]
    tx = x(stamps)
    paused = timeline.paused_samples()
    series = [
        (axes[1], 'memory_current_bytes', BLUE, '-', 'Cgroup memory.current'),
        (axes[1], 'anon_bytes', GOLD, '--', 'Anonymous memory'),
        (axes[2], 'disk_file_charge_bytes', GOLD, '--', 'Cgroup file - shmem charge'),
    ]
    for ax, key, color, style, label in series:
        values = np.asarray([m[key] / GIB for m in timeline.samples])
        if compact:
            # Keep every paused sample visible, without inventing time inside
            # a removed interval or discarding a pause-period memory peak.
            ax.plot(tx[~paused], values[~paused], color=color, ls=style, lw=1.2,
                    label=label, zorder=3)
            ax.scatter(tx[paused], values[paused], color=GRAY, s=3,
                       alpha=.42, linewidths=0, rasterized=True, zorder=2)
        else:
            ax.plot(tx, values, color=color, ls=style, lw=1.2, label=label, zorder=3)
    axes[1].set_ylabel('Memory (GiB)')
    if metrics['memory_events'].get('max', 0):
        axes[1].axhline(metrics['memory_limit_gib'], color=INK, ls=':', lw=1,
                       label='Configured limit (max event)')
    axes[1].set_ylim(0, max(metrics['peak_sampled_memory_bytes'] / GIB,
                            metrics['memory_limit_gib'] if metrics['memory_events'].get('max', 0) else 0) * 1.12)
    bt = x([b['finished_ns'] for b in timeline.boundaries])
    cache = [b['resident_bytes'] / GIB for b in timeline.boundaries]
    axes[2].plot(bt, cache, color=BLUE, ls=':', lw=1.1, marker='o', ms=3,
                 label='mincore: scanned rootfs file pages', zorder=4)
    axes[2].set_ylabel('Page Cache (GiB)')
    axes[2].set_ylim(0, max(max(cache), metrics['peak_disk_file_charge_bytes'] / GIB) * 1.12)
    for ax in axes[1:]:
        handles, labels = ax.get_legend_handles_labels()
        if ax is axes[2]:
            handles, labels = handles[::-1], labels[::-1]
        ax.legend(handles, labels, loc='lower left', bbox_to_anchor=(0, 1.02),
                  ncol=2, frameon=False, fontsize=8, borderaxespad=0,
                  handlelength=2.4, columnspacing=1.5)
    if titles:
        for ax, title in zip(axes, [
                'A  Per-call tool execution latency',
                'B  Container memory usage (200 ms sampling target)',
                'C  Page Cache: scanned rootfs files on the host']):
            ax.set_title(title, loc='left', fontsize=11, pad=32)
    unit = 'min' if scale == 60 else 's'
    label = f'Elapsed time ({unit}; pause / scan intervals removed)' if compact else f'Elapsed wall time ({unit}; includes pause / scan)'
    axes[-1].set_xlabel(label)


def plot_run(rec, pack, timeline, output_dir):
    metrics = pack[0]
    output_dir = Path(output_dir)
    for compact, filename in [(False, 'curves'), (True, 'curves-active')]:
        duration = float(timeline.seconds(timeline.end, compact))
        scale = 60 if duration >= 600 else 1
        fig, axes = plt.subplots(3, 1, figsize=(12, 10.2))
        axes[2].sharex(axes[1])
        axes[1].tick_params(labelbottom=False)
        fig.subplots_adjust(left=.095, right=.98, bottom=.125, top=.79, hspace=.8)
        fig.suptitle(rec['task_id'], x=.095, ha='left', fontsize=16, y=.975)
        mode = 'Pause-removed display' if compact else 'Recorded wall-clock timeline'
        fig.text(.095, .936, f"{mode} | {rec['run_id']}", fontsize=10, color=GRAY)
        fig.text(.095, .908,
                 f"{len(timeline.steps)} calls | {len(timeline.boundaries)} cache scans | 2 CPU | "
                 f"{metrics['memory_limit_gib']:g} GiB limit | warm cache baseline retained", fontsize=9, color=GRAY)
        fig.legend(handles=_phase_handles(timeline, compact), loc='lower left',
                   bbox_to_anchor=(.09, .855), ncol=3, frameon=False, fontsize=9)
        draw_panels(axes, timeline, metrics, compact=compact, scale=scale)
        if compact:
            note = 'Only pause/scan time is removed; gray dots retain samples from those pauses. Async waits remain.'
        else:
            note = 'Latency is grouped by tool call; memory/cache share wall time with tool, scan-pause and async-wait shading.'
        fig.text(.095, .06, note, fontsize=8, color=GRAY)
        fig.text(.095, .037,
                 'Cache dots = frozen scans; dotted line is a guide. Scope: rootfs files owned by host user rashen; not guest-wide cache.',
                 fontsize=8, color=GRAY)
        fig.text(.095, .014,
                 'No model thinking replayed. Async tool latency measures launch; background work can continue between calls.',
                 fontsize=8, color=GRAY)
        save_figure(fig, output_dir / filename)
        plt.close(fig)


def plot_comparison(recs, packs, timelines, output_dir):
    ordered = [next(r for r in recs if r['role'] != 'primary'),
               next(r for r in recs if r['role'] == 'primary')]
    fig, axes = plt.subplots(3, 2, figsize=(15.5, 10.2), sharey='row')
    axes[0, 1].sharex(axes[0, 0])
    for ax in [axes[1, 1], axes[2, 0], axes[2, 1]]:
        ax.sharex(axes[1, 0])
    for ax in axes[1, :]:
        ax.tick_params(labelbottom=False)
    fig.subplots_adjust(left=.075, right=.98, bottom=.12, top=.79, hspace=.8, wspace=.12)
    fig.suptitle('CompCert: 8 GiB and 32 GiB memory limits', x=.075, ha='left', y=.975, fontsize=16)
    fig.text(.075, .938, 'Recorded wall-clock timelines | 318 identical tool scripts per run | 2 CPU | one run per setting',
             fontsize=10, color=GRAY)
    fig.legend(handles=_phase_handles(timelines[ordered[0]['run_id']], False),
               loc='lower left', bbox_to_anchor=(.07, .886), ncol=3, frameon=False, fontsize=9)
    for col, rec in enumerate(ordered):
        metrics = packs[rec['run_id']][0]
        tl = timelines[rec['run_id']]
        draw_panels(list(axes[:, col]), tl, metrics, scale=60, titles=False, annotate=False)
        axes[0, col].set_title(f"{metrics['memory_limit_gib']:g} GiB limit | {rec['run_id']}",
                               fontsize=10, loc='left', pad=32)
        if col:
            for ax in axes[:, col]:
                ax.set_ylabel('')
    # Shared limits are chosen from both records, not whichever column drew last.
    all_metrics = [packs[r['run_id']][0] for r in ordered]
    axes[0, 0].set_ylim(0, max(a['tool_max_seconds'] for a in all_metrics) * 1.18)
    axes[1, 0].set_ylim(0, max(a['peak_sampled_memory_bytes'] / GIB for a in all_metrics) * 1.12)
    axes[2, 0].set_ylim(0, max(max(a['peak_file_resident_bytes'], a['peak_disk_file_charge_bytes']) / GIB for a in all_metrics) * 1.12)
    axes[2, 0].set_xlim(0, max((timelines[r['run_id']].end - timelines[r['run_id']].t0) / 60e9 for r in ordered) * 1.004)
    fig.text(.075, .055, 'Latency is grouped by call index. Memory/cache share elapsed wall time; blank tails follow the end of a run.',
             fontsize=8, color=GRAY)
    fig.text(.075, .033, 'Cache dots = frozen mincore scans of rootfs files owned by host user rashen. Host load, network and cache warmness were not controlled.',
             fontsize=8, color=GRAY)
    save_figure(fig, Path(output_dir) / 'comparison')
    plt.close(fig)
