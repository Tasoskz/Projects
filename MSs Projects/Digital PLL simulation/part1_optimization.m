%% Type-II ADPLL noise analysis/Transfer function plotting
clear; clc; close all;

% 1. Specifications
F_REF = 100e6;           
F_DCO = 2.4e9;           
N = F_DCO / F_REF;   
K_DCO = 25e3;      
xi = 1 / sqrt(2);
Delta_t_res = 2e-12;     
T_REF = 1/F_REF;

% loop
for f_3dB = 1.7e6:0.01e6:1.9e6
    wn = (2 * pi * f_3dB) / 2.06;
    rho = (wn / F_REF)^2;
    alpha = (2 * xi) * sqrt(rho);



% 2. Frequency Range
f = logspace(2, 10, 4000); 
s = 2*pi*1i*f;

% 3. Transfer Functions
den = s.^2 + alpha*F_REF.*s + rho*F_REF^2; %denominator
H_TDC_REF = N * (alpha*F_REF.*s...
    + rho*F_REF^2) ./ den; %reference and TDC transfer function
H_DCO = (s.^2) ./ den; % DCO transfer function

% 4. Noise Sources 
% in S_phi [rad^2/Hz], to make all the multiplications with the TF)
% *2 whenever I move from L to S, because S is double-band
S_phi_ref_raw = 2 * 10^(-155/10);
S_phi_tdc_raw = ((2*pi)^2 / (12 * F_REF))...
    * (Delta_t_res / T_REF)^2;
L_dco_therm_raw = -120 - 20*log10(f/1e6);
S_phi_dco_therm_raw = 2 * 10.^(L_dco_therm_raw/10);
S_phi_dco_quant_raw = (1 / (12 * F_REF))...
    * (K_DCO ./ f).^2 .* (sinc(f / F_REF)).^2;

% 5. Noise at the Output
S_phi_ref_out   = abs(H_TDC_REF).^2 .* S_phi_ref_raw;
S_phi_tdc_out   = abs(H_TDC_REF).^2 .* S_phi_tdc_raw;
S_phi_dco_out   = abs(H_DCO).^2 .* S_phi_dco_therm_raw;
S_phi_dcoq_out  = abs(H_DCO).^2 .* S_phi_dco_quant_raw;
S_phi_total_out = S_phi_ref_out + S_phi_tdc_out ...
    + S_phi_dco_out + S_phi_dcoq_out;

% 6. Convert to L(f) [dBc/Hz] for Plotting
% I divide by two since L is single band
PN_REF_out       = 10*log10(S_phi_ref_out / 2);
PN_TDC_out       = 10*log10(S_phi_tdc_out / 2);
PN_DCO_therm_out = 10*log10(S_phi_dco_out / 2);
PN_DCO_quant_out = 10*log10(S_phi_dcoq_out / 2);
PN_Total_out     = 10*log10(S_phi_total_out / 2);

% 7. Jitter Calculation (Individual Contributions)
jitter_conv = 1 / (2 * pi * F_DCO); %conversion factor from σφ το στ

sig_ref  = sqrt(trapz(f, S_phi_ref_out))   * jitter_conv;
sig_tdc  = sqrt(trapz(f, S_phi_tdc_out))   * jitter_conv;
ref_tdc_comb = sqrt(sig_ref^2+sig_tdc^2);
sig_dco  = sqrt(trapz(f, S_phi_dco_out))   * jitter_conv;
sig_dcoq = sqrt(trapz(f, S_phi_dcoq_out))  * jitter_conv;
dco_dcoq_comb = sqrt(sig_dco^2+sig_dcoq^2);
sig_tot  = sqrt(trapz(f, S_phi_total_out)) * jitter_conv;

% 8. Plotting
figure('Color', 'w');
semilogx(f, PN_REF_out, 'k', 'LineWidth', 1.5); 
hold on;
semilogx(f, PN_TDC_out, 'b', 'LineWidth', 1.5);
semilogx(f, PN_DCO_therm_out, 'r', 'LineWidth', 1.5);
semilogx(f, PN_DCO_quant_out, 'm', 'LineWidth', 1.5); 
semilogx(f, PN_Total_out, 'g', 'LineWidth', 2.5);

% background of the plot
set(gca, 'Color', 'w');       
set(gca, 'XColor', 'k');      
set(gca, 'YColor', 'k');      
set(gca, 'GridColor', 'k');   
set(gca, 'MinorGridColor', 'k'); 

% labeling and layout
grid on; 
grid minor;
xlabel('Offset Frequency (Hz)');
ylabel('Phase Noise (dBc/Hz)');
title(['ADPLL Analysis | Jitter: ', num2str(sig_tot * 1e15, ...
    '%.1f'), ' fs'], 'FontSize', 13, 'Color', 'k');
lgd = legend('REF', 'TDC', 'DCO Thermal', 'DCO Quant', 'Total PN', ...
    'Location', 'southwest');
set(lgd, 'TextColor', 'k', 'Color', 'w', 'EdgeColor', 'k');
ylim([-200 -110]);
xlim([1e2 1e9]);


% Printed Output
fprintf('--- Integrated RMS Jitter Contributions ---  %.2f MHz\n', f_3dB*1e-6);
fprintf('Reference:         %.2f fs\n', sig_ref  * 1e15);
fprintf('TDC Quantization:  %.2f fs\n', sig_tdc  * 1e15);
fprintf('Combined Reference and TDC: %.2f fs\n', ref_tdc_comb * 1e15);
fprintf('DCO Thermal:       %.2f fs\n', sig_dco  * 1e15);
fprintf('DCO Quantization:  %.2f fs\n', sig_dcoq * 1e15);
fprintf('Combined DCO and DCO Quantization: %.2f fs\n', dco_dcoq_comb * 1e15);
fprintf('-------------------------------------------\n');
fprintf('Total RMS Jitter:  %.2f fs\n', sig_tot  * 1e15);
end

