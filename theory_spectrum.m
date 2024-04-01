%% theory_spectrum_label_create
clc; clear; close all;
wave_range = 400:1:900;
% training part
step_train = 8;
ip_wave_range_train = 1:step_train:size(wave_range,2);
wave_range_train = wave_range(1,ip_wave_range_train);
num_train = 20000;
spec_label_train_pre = zeros(num_train,size(wave_range_train,2));
spec_label_train = zeros(num_train,size(wave_range,2));
power_train = zeros(1,num_train);
for i = 1:num_train
    istrue_train = 0;
    while istrue_train ~=1
        spec_label_train_pre(i,:) = rand(1,size(wave_range_train,2)) * 0.6 + 0.2;
        spec_label_train(i,:) = interp1(wave_range_train,spec_label_train_pre(i,:),wave_range,'pchip');
        if max(spec_label_train(i,:))<0.82&&min(spec_label_train(i,:))>0.18
            istrue_train = 1;
            power_train(1,i) = spec_label_train(i,1);
        end
    end
end

% test part
step_test = 30;
ip_wave_range_test = 1:step_test:size(wave_range,2);
wave_range_test = wave_range(1,ip_wave_range_test);
num_test = 5000;
spec_label_test_pre = zeros(num_test,size(wave_range_test,2));
spec_label_test = zeros(num_test,size(wave_range,2));
power_test = zeros(1,num_test);
for i = 1:num_test
    istrue_test = 0;
    while istrue_test ~=1
        spec_label_test_pre(i,:) = rand(1,size(wave_range_test,2)) * 0.6 + 0.2;
        spec_label_test(i,:) = interp1(wave_range_test,spec_label_test_pre(i,:),wave_range,'pchip');
        if max(spec_label_test(i,:))<0.82&&min(spec_label_test(i,:))>0.18
            istrue_test = 1;
            power_test(1,i) = spec_label_test(i,1);
        end
    end
end

% result 
figure(1)
subplot(1,4,1);
for i = 1 %:size(spec_label_train_pre,1)
    plot(wave_range_train, spec_label_train_pre(i,:));
    hold on;
end
title('spec-label-train-before', 'Interpreter','none');
subplot(1,4,2);
for i = 1 %:size(spec_label_train,1)
    plot(wave_range, spec_label_train(i,:));
    hold on;
end
title('spec-label-train-after', 'Interpreter','none');
subplot(1,4,3);
for i = 1 % :size(spec_label_test_pre,1)
    plot(wave_range_test, spec_label_test_pre(i,:));
    hold on;
end
title('spec-label-test-before', 'Interpreter','none');
subplot(1,4,4);
for i = 1 % :size(spec_label_test,1)
    plot(wave_range, spec_label_test(i,:));
    hold on;
end
title('spec-label-test-after', 'Interpreter','none');

