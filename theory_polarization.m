%% theory_polarization_label_create
clc; clear; close all;

theta_amp_class = 0:2:178;
theta_diff_class = 0:2:178;
theta_amp = zeros(1,length(theta_amp_class)*length(theta_diff_class));
theta_diff = zeros(1,length(theta_amp_class)*length(theta_diff_class));
amplitude = 1;

for i = 1:length(theta_amp_class)
    for j = 1:length(theta_diff_class)

    theta_amp(i*length(theta_diff_class)-length(theta_diff_class)+j) = theta_amp_class(i);
    theta_diff(i*length(theta_diff_class)-length(theta_diff_class)+j) = theta_diff_class(j);
    end
end
theta_diff = deg2rad(theta_diff);

stokes = zeros(length(theta_diff),4);
input = zeros(length(theta_amp),2);
for i = 1:length(theta_amp)
    E_x = amplitude * cosd(theta_amp(i));
    E_y = amplitude * sind(theta_amp(i)) * exp(1i*theta_diff(i));
    S_0 = E_x*conj(E_x) + E_y*conj(E_y);
    S_1 = E_x*conj(E_x) - E_y*conj(E_y);
    S_2 = real(2*E_x*E_y);
    S_3 = imag(-2*E_x*E_y);
    S_1 = S_1 / S_0;
    S_2 = S_2 / S_0;
    S_3 = S_3 / S_0;
    stokes(i,:) = [S_0, S_1, S_2, S_3];
    input(i,:) = [E_x, E_y];
end
stokes(abs(stokes)<10e-16) = 0;
stokes(stokes>1-10e-16) = 1;
stokes(stokes<-1+10e-16) = -1;  

[B,ia,ib] = unique(stokes,'rows');
dup = setdiff(1:size(stokes,1),ia)';
stokes_class_pre(dup,:) = [];
stokes(dup,:) = [];
input(dup,:) = [];

spec_label = stokes;
