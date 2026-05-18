%% Time model of the DCO
clear all; 
clc;
close all;

% 1. Specifications
f_ref = 100e6;  
T_ref = 1/f_ref;
f_dco = 2.4e9;
T_dco = 1/f_dco;
f_off = 1e6;
len = 1e6; % number of cycles             
Delta_t_res = 2e-12;

% 2. Frequency Range
f = logspace(1, 10, 4000); 
s = 2*pi*1i*f;

%% Question A

% 1. Calculating the noise at  the 0dB/dec region [rad^2/Hertz]
S_ref = 2 * 10^(-155/10); 

%  2. Calculating the jitter for the 0dB/dec region
sigma_t_floor = (1/(2*pi*f_dco)) * sqrt(S_ref * f_dco);


% 3. Generating timestamps of oscillator's rising edges
for i=1:len
CKV(i) = i * T_dco + sigma_t_floor * randn(1);
end

% 4. Calculating time deviation of each oscillator's 
% rising edge for its ideal position

tdev = CKV - (T_dco*(1:len)); 

% 5. Calculating period and edge-to-edge jitter

period = CKV(2:len) - CKV(1:len-1); 
dT = 1 * (period - T_dco);

% 6. Calculating Phase error of all oscillator edges

phase = 2 * pi * tdev / T_dco;

% 7. Calculating Phase noise 

[Y,f] = pwelch(phase,blackmanharris(length(phase)/20),[],[],...
    f_dco,'onesided'); 
PN_SSB = 10 * log10(Y)-6;

% 8. Plotting
% Figure 1
figure('Color','w');
semilogx(f, PN_SSB, 'b-','LineWidth',1); 

% background of the plot
set(gca, 'Color', 'w');       
set(gca, 'XColor', 'k');      
set(gca, 'YColor', 'k');      
set(gca, 'GridColor', 'k');   
set(gca, 'MinorGridColor', 'k'); 

% labeling and layout
grid on; 
grid minor;
xlabel('Offset Frequency [Hz]');
ylabel('Phase Noise [dBc/Hz]');
title('REF Oscillator – Phase Noise', 'Color', 'k'); 
ylim([-160, -140]);
xlim([1e4, 1e8]);

% Figure 2
figure('Color','w');

% Plotting
subplot(1,2,1);
plot((1:len)*T_dco*1e6, tdev*1e15, 'b', 'LineWidth', .5);
xlabel('Time [\mus]'); 
ylabel('Time Deviation [fs]');
title('REF Oscillator – Time Deviation', 'Color', 'k');
grid on; 
xlim([0, len*T_dco*1e6]);

% background of the plot
set(gca, 'Color', 'w');       
set(gca, 'XColor', 'k');      
set(gca, 'YColor', 'k');      
set(gca, 'GridColor', 'k');   
set(gca, 'MinorGridColor', 'k');

subplot(1,2,2);
histogram(dT, 100, 'FaceColor', [0.2 0.4 0.8]);
xlabel('edge-to-edge jitter'); 
ylabel('Number');
title('Histogram', 'Color', 'k');

% background of the plot
set(gca, 'Color', 'w');       
set(gca, 'XColor', 'k');      
set(gca, 'YColor', 'k');      
set(gca, 'GridColor', 'k');   
set(gca, 'MinorGridColor', 'k');


%% Question B

% 1. Calculating the noise at  the 0dB/dec region [rad^2/Hertz]
S_thermal = 2 * 10^(-120/10); 

% 2. Calculating the jitter for the 0dB/dec region
sigma_t = (f_off/f_dco) * sqrt(S_thermal / f_dco);

% 3. Generating timestamps of oscillator's rising edges
tv1 = 0;
tv2 = 0;
for i=1:len
dco_NF = sigma_t_floor * randn(1);
tv1 = i * T_dco + dco_NF;
dco_wander = sigma_t * randn(1); 
tv2 = tv2 + dco_wander;
CKV(i) = tv1 + tv2;
end

% 4. Calculating time deviation of each oscillator's 
% rising edge for its ideal position

tdev = CKV - (T_dco*(1:len)); 

% 5. Calculating period and edge-to-edge jitter

period = CKV(2:len) - CKV(1:len-1); 
dT = 1 * (period - T_dco);

% 6. Calculating Phase error of all oscillator edges

phase = 2 * pi * tdev / T_dco;

% 7. Calculating Phase noise 

[Y,f] = pwelch(phase,blackmanharris(length(phase)/20),[],[],...
    f_dco,'onesided'); 
PN_SSB = 10 * log10(Y)-3;

% 8. Plotting
% Figure 1
figure('Color','w');
semilogx(f, PN_SSB, 'b-','LineWidth', 1); 

% background of the plot
set(gca, 'Color', 'w');       
set(gca, 'XColor', 'k');      
set(gca, 'YColor', 'k');      
set(gca, 'GridColor', 'k');   
set(gca, 'MinorGridColor', 'k'); 

% labeling and layout
grid on; 
grid minor;
xlabel('Offset Frequency [Hz]');
ylabel('Phase Noise [dBc/Hz]');
title('REF Oscillator – Phase Noise', 'Color', 'k'); 
ylim([-160, -100]);
xlim([1e5, 1e9]);

% Figure 2
figure('Color','w');

% Plotting
subplot(1,2,1);
plot((1:len)*T_dco*1e6, tdev*1e15, 'b', 'LineWidth', .5);
xlabel('Time [\mus]'); 
ylabel('Time Deviation [fs]');
title('REF Oscillator – Time Deviation', 'Color', 'k');
grid on; 
xlim([0, len*T_dco*1e6]);

% background of the plot
set(gca, 'Color', 'w');       
set(gca, 'XColor', 'k');      
set(gca, 'YColor', 'k');      
set(gca, 'GridColor', 'k');   
set(gca, 'MinorGridColor', 'k');

subplot(1,2,2);
histogram(dT, 100, 'FaceColor', [0.2 0.4 0.8]);
xlabel('edge-to-edge jitter'); 
ylabel('Number');
title('Histogram', 'Color', 'k');

% background of the plot
set(gca, 'Color', 'w');       
set(gca, 'XColor', 'k');      
set(gca, 'YColor', 'k');      
set(gca, 'GridColor', 'k');   
set(gca, 'MinorGridColor', 'k');
