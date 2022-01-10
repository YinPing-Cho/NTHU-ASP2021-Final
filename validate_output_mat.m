clear;
load ans_static.mat;
load ans_qstatic.mat;
load ans_varying.mat;

disp(calc_binary_ratio(ans_static_1))
disp(calc_binary_ratio(ans_static_2))

disp(calc_binary_ratio(ans_qstatic_1))
disp(calc_binary_ratio(ans_qstatic_2))

disp(calc_binary_ratio(ans_varying_1))
disp(calc_binary_ratio(ans_varying_2))

function ratio = calc_binary_ratio(seq)
    ratio = sum(seq(:) == 1) / sum(seq(:) == -1);
end
