# 数据校验与复现状态

> 公开范围：本次只提交文档、图表、汇总/CSV、配置与脚本。完整原始日志、轨迹和重放输入包保留在 cpu-15；重算/重放须提供 ASWR_ARCHIVE_ROOT，见[数据说明](data-and-sources.md)。
评估：**可用于初筛与资源行为描述，必须携带测量口径限制。** 这是十任务主结果和一次 CompCert 受限对照的单次实验记录，没有多租户/DAX 性能结论。

## 采集完整性

报告构建器直接从 11 份原始压缩 JSONL 重算，而不是手抄旧报告：

- 主结果十项共 652 次调用、662 个缓存边界；加原 CompCert 8 GiB 运行，共 970 次调用、981 个边界。
- 每个 run 检查工具编号连续、调用数与 normalized-steps 相同、初始加逐工具的 N+1 边界。
- 所有边界 frozen_verified=true，两遍扫描 changed_pages=0，无扫描错误；监控无记录错误。
- memory.peak 与原 summary 对齐，工具时延合计独立重算并核对原值；内存时戳顺序与最大间隔保留。
- 所有完成运行容器均已删除，没有 OOM；CompCert 8 GiB 的 max=31 单独揭示，32 GiB 主记录没有限额事件。
- 原始来源完整性、计时/缓存校准、冻结确认和静态读取桥接检查在 [collection-checks](../provenance/collection-checks) 中保留。

机器可读的逐项检查见 [report-validation.json](../provenance/report-validation.json)。

## 正确性与范围校验

每份任务文档明确完整重放、本地验证、官方判题的区别。重点保留：PDF.js 仅 setup/CLI；CSV 源判题失败；Django 原 Agent 超时且本轮仅语法检查；Log4j2 跳过测试且原附加检查 141 仍在；Matplotlib 是公开局部测试；CompCert 有三处源退出状态差异，异步启动时间不能当作构建总时间。

token 任务会加载 1,000 行 metadata，再筛选 26 行计数，不把 26 行说成未下载其他行，也不称为全量大规模数据处理。源 API 返回、模型快照多格式下载、镜像暖缓存与业务实际访问分开描述。

## 图表与解释核对

所有图由 `scripts/build_results.py` 生成，采用从 0 开始的纵轴、明确单位、独立的工具编号/墙钟横轴，区分 cgroup memory、匿名内存、根文件驻留和 file−shmem 计费。初始驻留保留；不将不同分量峰值相加。CompCert 主设置与受限对照在图题和表格中标注。

图表的人工预览结果、覆盖和归档检查保存于 [qa-review.json](../provenance/qa-review.json)。按图审阅后才将状态标为完成。表格以原始数据计算，展示值按统一精度取舍，不使用绘图抽样后的数值汇总。

## 可重复检查

```bash
MPLCONFIGDIR=/tmp/aswr-matplotlib python3 scripts/build_results.py
python3 scripts/verify_archive.py
```

构建图表会更新派生文件；若有意修改报告/图表，审核后更新校验清单：

```bash
python3 scripts/verify_archive.py --write-manifest
python3 scripts/verify_archive.py
```

公开包检查器验证文件哈希与 Markdown 本地链接；原压缩包字节哈希检查在完整本地归档中运行。README 的源模板位于 docs/templates，仅为构建输入，不是单独的阅读入口。

部署准备脚本已做语法检查、临时目录展开/静态探针编译与十项镜像 dry-run 检查。这只验证打包入口，不表示本轮整理时重新跑过十项或重新确认全部联网依赖可用。原运行成功证据以 run ID、image ID、数值与日志为准；上游 apt/npm/pip、网络和共享宿主变化可能影响新运行。

## 当前结论的限制与下一步

预热与共享宿主未隔离，各配置仅一次；容器指标无法替代 guest 物理内存。根文件驻留包含未在轨迹中访问的镜像缓存，没有 read/write 字节或 PFN 唯一页证据。Matplotlib 所有权兼容与扫描排除量均需保留。

下一阶段先固定只读输入/快照与缓存策略，对优先候选做多个并发 sandbox 的受控复测，补充实际文件访问和唯一物理页证据，再接入 DAX 对照。当前没有足够数据回答“可共享多少内存”或“DAX 提升多少性能”。
