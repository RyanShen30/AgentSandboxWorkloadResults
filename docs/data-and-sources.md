# 数据、来源与公开范围

本次公开提交包含 README、十任务文档、PNG/SVG、汇总 JSON/CSV、逐工具时延 CSV、边界指标 CSV、运行配置、检查证据和采集器/部署脚本。

完整连续原始序列、逐步命令与输出日志、完整原轨迹以及 replay-inputs 压缩包保留在 cpu-15，不纳入此次公开提交。原始实验目录为 `/home/rashen/work/AgentWorkloadProbe-20261020`；完整打包副本为 `/home/rashen/work/AgentSandboxWorkloadResults` 中被 Git 忽略的归档文件。镜像层不进 Git。

## 来源

每个任务的 `experiments/container-screening/workloads/<task>/provenance.json` 列出公开来源 URL、下载内容 SHA-256 与可用的 revision。它只保留来源元数据，不包含原始观察全文。每任务结果文档直接链接原公开轨迹。

- [Lottolabs Terminal-Bench 社区轨迹](https://huggingface.co/datasets/Lottolabs/terminal-bench-2.1-qwen3.8-27b-traces/tree/dbf15f8e97ec7510c55f97fd66748888b2a27ad5/xhigh/traces)：C4、CSV、HF、Cython、token、CompCert。
- [RepoLaunch PDF.js setup.log](https://github.com/SWE-bench-Live/RepoLaunch-trajectory-archive/blob/main/linux_tasks/js/playground/mozilla__pdf.js-20957/setup.log)：仅环境准备和 CLI 测试。
- [EnvBench JVM 轨迹](https://huggingface.co/datasets/JetBrains-Research/EnvBench-trajectories/tree/4ffd02bed0f39fd87bffe3be7edf2440aba16cd1/jvm/bash_agent-4o/trajectories)：Log4j2。
- [Devstral2 Matplotlib 轨迹](https://huggingface.co/datasets/pankajmathur/devstral2-123b-swebench-verified-traj/tree/d159b42a372985a36c6e227d5910c44b707551ca/matplotlib__matplotlib-24177)。
- [Qwen3 Django 轨迹](https://huggingface.co/datasets/hngl/swebench-verified-sample-100-Qwen3-30B-eval/tree/151694b6e97e29679076086b2e0f90e532676570/django__django-16819__CbaXz2n)。

原来从 main 下载的环境定义/setup.log 以内容哈希固定，不冒称固定了源仓库提交。上游 apt/npm/pip、部分数据及 tokenizer URL 没有形成封闭离线快照。

## 本地重算或重放

公开仓库的图表和汇总可直接阅读；全量重算/重放需要原服务器归档。在 cpu-15 上，例如：

```bash
ASWR_ARCHIVE_ROOT=/home/rashen/work/AgentSandboxWorkloadResults \
  MPLCONFIGDIR=/tmp/aswr-matplotlib python3 scripts/build_results.py
```

`materialize_replay.py` 同样从 ASWR_ARCHIVE_ROOT 读取固定 replay-inputs 包；新机器需要另行取得这些输入，不能仅凭本次文档提交声称已具备完整离线重放环境。原采集器、镜像固定信息和环境操作见[部署文档](deployment/README.md)。

`scripts/verify_archive.py` 核对本次公开包；`verify_full_archive.py` 用于完整本地归档。此前 4,312 项原文件字节哈希检查针对完整本地包，不表示这些原始文件都已发布。完整上游数据、模型与源码继续适用各上游项目的条件。
