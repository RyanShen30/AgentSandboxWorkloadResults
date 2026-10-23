# 诊断与失败尝试

所有业务执行尝试均保留，不按时延或缓存大小挑选主记录。准备阶段失败另见部署记录。

| 运行 | 原因 | 退出码一致 | 独立验证 |
| --- | --- | --- | --- |
| [build-cython-ext-20261023T153041Z-590984](build-cython-ext-20261023T153041Z-590984/summary.json) | Git promisor fetch connection reset at step47; retained; repeat planned with working proxy and HTTP/1.1 | False | PASS |
| [hf-model-inference-20261023T154637Z-594275](hf-model-inference-20261023T154637Z-594275/summary.json) | direct Hugging Face TLS reset; model download and independent validation failed | False | FAIL |
| [count-dataset-tokens-20261023T162720Z-612179](count-dataset-tokens-20261023T162720Z-612179/summary.json) | Hugging Face TLS EOF on metadata/download URLs; answer artifact absent; kept as diagnostic; fresh-VM retry after endpoint recovery passed unchanged inputs | False | FAIL |
| [compile-compcert-20261023T164620Z-620929](compile-compcert-20261023T164620Z-620929/summary.json) | host upstream proxy port expired: Dune step223 download failed and five later commands lacked files; final compiler smoke PASS; kept as diagnostic; retry uses reloadable upstream plus metadata preflight | False | PASS |
| [compile-compcert-20261023T173225Z-639078](compile-compcert-20261023T173225Z-639078/run.json) | preflight assumed Python in minimal base image; stopped before any original business action; fixed to controller HEAD plus guest Bash CONNECT; guest deleted | incomplete | not counted |
