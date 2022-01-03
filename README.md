# NTHU-ASP2021-Final
Final project repo for grad-level Adaptive Signal Processing course at National Tsinghua University, Taiwan.

# Update 2022/01/02
- 請更新至 v1.2.0。
- 已可`test_bench.m`完整進行 LMS, LMS-DFE, NLMS-DFE, RLS-DFE 測試，輸出結果請見`TestFigs`和`TestBenchResults`。
- `main.m` 可讀取課程期末的測資、以指定的演算法濾波、並把結果按照規定輸出，error-curves輸出在`MainFigs`。

# Update 2021/12/31
- 請使用 v1.1.0 來整合、測試不同的演算法，避免不同演算法測試編輯參數時的衝突。
- v1.1.0 將不同演算法的參數維持在獨立的 `PARAMS_*.m` 檔案裏面，請將自己的演算法的參數儲存在當中、實驗不同參數時只需編輯 `PARAMS_*.m` 檔案。

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
- [x] `main.m`
- [x] `shared_utils.m`
- [x] `algorithm_LMS.m`
- [x] `algorithm_LMS_DFE.m`
- [x] `algorithm_NLMS_DFE.m`
- 昊平：RLS-DFE
- [x] `algorithm_RLS_DFE.m`
- 宣妤、若盈：
- [ ] RLS-DFE 最佳參數尋找
- [ ] 報告實驗設計與結果收集
