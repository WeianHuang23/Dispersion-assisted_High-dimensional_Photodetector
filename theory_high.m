%% theory_high_spectrum_label_create
clc; clear; close all;
wave_range = 400:1:900;
% training part
step_train = 8;
ip_wave_range_train = 1:step_train:size(wave_range,2);
wave_range_train = wave_range(1,ip_wave_range_train);
num_train = 40000;
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
num_test = 10000;
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

% save part
spec_label.spec_label_train = spec_label_train;
spec_label.spec_label_test = spec_label_test;
% save('./high_spec_label.mat','spec_label');


%% theory_high_polarization_label_create
clc; close all; clear;
wave_range = 400:1:900;

% polarization
i1 = 1;i2 = 1;
list = linspace(0,180,5000);
list = list(1,2:end-1);
delta2 = 1/2*pi;
for ang1 = 0
    theta1 = deg2rad(ang1);
    input = [cos(theta1);sin(theta1)];
    for jkl = 1:size(list,2)
        theta2 = deg2rad(list(jkl));
        P2(:,:,i2)=(exp(-1/2*1i*delta2))*[cos(theta2)^2+exp(1i*delta2)*sin(theta2)^2 (1-exp(1i*delta2))*cos(theta2)*sin(theta2);(1-exp(1i*delta2))*cos(theta2)*sin(theta2) sin(theta2)^2+exp(1i*delta2)*cos(theta2)^2];
        output(:,i2) = P2(:,:,i2)*input;
        a = output(1,i2);
        b = output(2,i2);
        
        err = 1e-10;
        if abs(a)<err
            a = 0;
        end
        if abs(b)<err
            b = 0;
        end
        stokes(i2,1) = abs(a.^2)+abs(b.^2);
        stokes(i2,2) = (abs(a.^2)-abs(b.^2))./stokes(i2,1);
        stokes(i2,3) = (real(2.*a.*b'))./stokes(i2,1);
        stokes(i2,4) = (imag(-2.*a.*b'))./stokes(i2,1);
        if abs(stokes(i2,2))<err
            stokes(i2,2) = 0;
        end
        if abs(stokes(i2,3))<err
            stokes(i2,3) = 0;
        end
        if abs(stokes(i2,4))<err
            stokes(i2,4) = 0;
        end
        i2 = i2+1;       
    end  
    i1 = i1+1;
end

% load spectrum label
load('./high_spec_label.mat');

% training part
spec_label_train_pre = spec_label.spec_label_train';
num_spec_train = size(spec_label_train_pre,2);
step_train = 25;
ip_wave_range_train = 1:step_train:size(wave_range,2);
wave_range_train = wave_range(1,ip_wave_range_train);
ip_stokes_train = zeros(num_spec_train,size(wave_range,2));
spec_label_train = zeros(num_spec_train,size(spec_label_train_pre,1)*4);
for i = 1:num_spec_train % size(spec_label_pre,2)
    ishigh = 1;
    while ishigh ~= 0
        ip_stokes_pre = randi(size(stokes,1),1,size(wave_range_train,2));
        ip_stokes_pre = unique(ip_stokes_pre);
        while size(ip_stokes_pre,2) ~= size(wave_range_train,2)
            ip_stokes_pre = [ip_stokes_pre, randi(size(stokes,1),1,1)];
            ip_stokes_pre = unique(ip_stokes_pre);
        end
        ip_stokes_train(i,:) = interp1(wave_range_train,ip_stokes_pre,wave_range,'pchip');
        ip_stokes_train(i,:) = floor(ip_stokes_train(i,:));
        ishigh_vector = ip_stokes_train(i,2:end) - ip_stokes_train(i,1:end-1);
        ishigh = sum(ishigh_vector<=0);
        if isempty(find(ip_stokes_train(i,:)<1)) && isempty(find(ip_stokes_train(i,:)>size(stokes,1)))
        else
            ishigh = 1;
        end
    end
    spec_label_1 = [spec_label_train_pre(:,i), stokes(ip_stokes_train(i,:),2:end)];
    spec_label_1 = spec_label_1';
    spec_label_2 = reshape(spec_label_1,1,[]);
    spec_label_train(i,:) = spec_label_2;
end

% test part
spec_label_test_pre = spec_label.spec_label_test';
num_spec_test = size(spec_label_test_pre,2);
step_test = 15;
ip_wave_range_test = 1:step_test:size(wave_range,2);
wave_range_test = wave_range(1,ip_wave_range_test);
ip_stokes_test = zeros(num_spec_test,size(wave_range,2));
spec_label_test = zeros(num_spec_test,size(spec_label_test_pre,1)*4);
for i = 1:num_spec_test
    ishigh = 1;
    while ishigh ~= 0
        ip_stokes_pre = randi(size(stokes,1),1,size(wave_range_test,2));
        ip_stokes_pre = unique(ip_stokes_pre);
        while size(ip_stokes_pre,2) ~= size(wave_range_test,2)
            ip_stokes_pre = [ip_stokes_pre, randi(size(stokes,1),1,1)];
            ip_stokes_pre = unique(ip_stokes_pre);
        end
        ip_stokes_test(i,:) = interp1(wave_range_test,ip_stokes_pre,wave_range,'pchip');
        ip_stokes_test(i,:) = floor(ip_stokes_test(i,:));
        ishigh_vector = ip_stokes_test(i,2:end) - ip_stokes_test(i,1:end-1);
        ishigh = sum(ishigh_vector<=0);
        if isempty(find(ip_stokes_test(i,:)<1)) && isempty(find(ip_stokes_test(i,:)>size(stokes,1)))
        else
            ishigh = 1;
        end
    end
    spec_label_1 = [spec_label_test_pre(:,i), stokes(ip_stokes_test(i,:),2:end)];
    spec_label_1 = spec_label_1';
    spec_label_2 = reshape(spec_label_1,1,[]);
    spec_label_test(i,:) = spec_label_2;
end

% result
for i = 1:12
    figure(2),
    subplot(3,4,i),plot(ip_stokes_train(i,:));
end

for i = 1:12
    figure(1),
    subplot(3,4,i),plot(ip_stokes_test(i,:));
end
