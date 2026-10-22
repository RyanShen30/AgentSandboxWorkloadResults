# 十任务实验结果

> 公开范围：本次只提交文档、图表、汇总/CSV、配置与脚本。完整原始日志、轨迹和重放输入包保留在 cpu-15；重算/重放须提供 ASWR_ARCHIVE_ROOT，见[数据说明](../docs/data-and-sources.md)。
主结果采用每任务一个完整运行，CompCert 使用 32 GiB 复测；另保留其 8 GiB 原记录。所有数值从压缩原始 JSONL 重算，未对连续序列降采样。总体指标见[根 README](../README.md)与[summary.csv](summary.csv)。

| 任务 | 调用数 | 结果文档 |
| --- | ---: | --- |
| C4 压缩/解压 | 36 | [reshard-c4-data](reshard-c4-data/README.md) |
| 百万行 CSV | 50 | [large-scale-text-editing](large-scale-text-editing/README.md) |
| HF 模型推理 | 11 | [hf-model-inference](hf-model-inference/README.md) |
| PDF.js 环境与 CLI | 5 | [mozilla__pdf.js-20957](mozilla__pdf.js-20957/README.md) |
| Cython 扩展 | 83 | [build-cython-ext](build-cython-ext/README.md) |
| token 计数 | 16 | [count-dataset-tokens](count-dataset-tokens/README.md) |
| Log4j2 编译 | 10 | [apache__logging-log4j2](apache__logging-log4j2/README.md) |
| CompCert | 318 | [compile-compcert](compile-compcert/README.md)，含两轮对照 |
| Matplotlib | 95 | [matplotlib__matplotlib-24177](matplotlib__matplotlib-24177/README.md) |
| Django | 28 | [django__django-16819](django__django-16819/README.md) |

每份文档包含实际执行范围、工具统计、内存/驻留表、三项曲线、文件区域、较慢工具、适配/权限限制、来源和复现入口。日志、配置与完整数值在各任务 `runs/<run-id>/` 中。取消、预检或失败诊断运行不计入本表；它们仍保留于 cpu-15 原实验目录。

每个任务的“三项曲线”第一幅按调用序号展示工具时延；内存和 Page Cache 两幅共用时间轴，提供完整墙钟图与去除扫描暂停的辅助图。蓝色阴影标出工具执行区间；第三幅明确标为 Page Cache。具体定义见[时间轴说明](../docs/measurement.md#时间轴与未测项)。
