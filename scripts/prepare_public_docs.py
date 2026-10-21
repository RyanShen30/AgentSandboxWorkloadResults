#!/usr/bin/env python3
from pathlib import Path
import re
def sanitize(root):
 for p in root.rglob('*.md'):
  if 'templates' in p.parts:continue
  s=p.read_text()
  def link(m):
   label,target=m.group(1),m.group(2)
   if target.split('#',1)[0].endswith('.gz'):return label+'（原始归档留在 cpu-15）'
   return m.group(0)
  s=re.sub(r'\[([^\]]+)\]\(([^)]+)\)',link,s)
  s=s.replace('原始数值、日志和命令已归档，容器镜像/层不进 Git。','本次公开提交包含文档、图表、汇总、可读 CSV 和脚本；完整压缩原始序列、日志与轨迹单独保留在 cpu-15。')
  s=s.replace('并保留可重算的完整数值序列。','完整数值序列单独保留在 cpu-15，可提供本地归档用于重算。')
  s=s.replace('只重算报告，不运行任务（cpu-15 当前 Python 已有绘图依赖）：','复算需要 cpu-15 的完整本地归档；在新 checkout 中先设置 ASWR_ARCHIVE_ROOT。只阅读本仓库的文档、图表和汇总不需要这些归档。')
  s=s.replace('数值序列、逐步命令和普通文件日志均有完整归档','数值序列、逐步命令和普通文件日志在 cpu-15 均有完整归档')
  p.write_text(s)
if __name__=='__main__':sanitize(Path(__file__).resolve().parents[1])
