# NTHU-ASP2021-Final
Final project repo for grad-level Adaptive Signal Processing course at National Tsinghua University, Taiwan.

# Guide for writing `algorithm_*.m` functions
- __Three__ inputs are given:
 1. `TestCase_Params.*TestCase*` struct: The subsidiary parameters for the specified test case, such as the length of training sequence, length of data sequence, parameters for the specific algorithm, etc.
 2. `known_train_seq` array: the (1, train_L) sequence that is known and should be used in the training phase as the target signal.
 3. `full_noised_signal_seq` array: the (1, (train_L+data_L)*N) sequence that include both the training sequence(s) and data sequence(s).
- __Two__ outputs should be returned:
 1. `squared_error_seq` array: the (1, train_L*N) sequence that records the squared error curve during the training phase.
 2. `pred_signal` array: the (1, (data_L)*N) sequence that contains __ONLY the PREDICTION__ of unknown data sequence. _Don't return the prediction of the training sequence(s) here._
- Note: `N` above is the number of repetition for one (1, train_seq+data_seq) sequence, e.g., in the static case, N=1; in the official test data, N=200 for the q-static case, and N=500 for the time-varying case.

# Code Architecture
- `test_bench.m`: the run file for custom testcases comparing different algorithms. Depends on `algorithm_*.m` and `shared_utils.m`.
- `main.m`: the run file that loads, applies adaptive processing, and dumps the required benchmark signals. Depends on `algorithm_*.m` and `shared_utils.m`.
- `algorithm_*.m`: different adaptive algorithms, contains functions only. One and only one algorithm should be contained in one of these files. Each one only depends on `shared_utils.m`
- `shared_utils.m`: contains general utilities that can be called across the system. Such as MSELoss function, visualization functions, and custom autocorrelation calculation functions, etc.

# Algorithms to be implemented:
- RLS-DFE (2015)
- NLMS-DFE (2008 good for time-varying)
- LMS-DFE

# 分工:
- 引平：共用code架構+實作LMS-DFE測試。
- [x] `test_bench.m`
- [ ] `main.m`
- [x] `shared_utils.m`
- [x] `algorithm_LMS.m`
- [ ] `algorithm_LMS_DFE.m`
- 昊平、宣妤：RLS-DFE
- [x] `algorithm_RLS_DFE.m`
- 若盈：NLMS-DFE
- [ ] `algorithms_NLMS_DFE.m`
