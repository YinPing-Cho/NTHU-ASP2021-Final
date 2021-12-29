# NTHU-ASP2021-Final
Final project repo for grad-level Adaptive Signal Processing course at National Tsinghua University, Taiwan.

# Code Architecture
- `test_bench.m`: the run file for custom testcases comparing different algorithms. Depends on `algorithm_*.m` and `shared_utils.m`.
- `main.m`: the run file that loads, applies adaptive processing, and dumps the required benchmark signals. Depends on `algorithm_*.m` and `shared_utils.m`.
- `algorithm_*.m`: different adaptive algorithms, contains functions only. One and only one algorithm should be contained in one of these files. Each one only depends on `shared_utils.m`
- `shared_utils.m`: contains general utilities that can be called across the system. Such as MSELoss function, visualization functions, and custom autocorrelation calculation functions, etc.

# Algorithms to be implemented:
- DFE-RLS (2015)
- NLMS-DFE (2008 good for time-varying)
- 
