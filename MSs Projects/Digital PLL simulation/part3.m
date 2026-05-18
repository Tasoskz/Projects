clear; clc; close all;

% 1. Specifications
f_ref = 100e6;
f_dco = 2.4e9;
Delta_F = -20e6;
f_init_dco = f_dco - Delta_F; % DCO starts a bit slower
f_off = 1e6;
N = f_dco / f_ref;
T_ref = 1/f_ref;
T_o = 1/f_dco;
T_init_dco = 1 / f_init_dco;
alpha = 76.78 * 10^-3;
rho = 2.95 * 10^-3;
K_dco = 25e3;
K_T = K_dco / f_dco^2;
Delta_tres = 2e-12;
f = logspace(2, 10, 4000); 
s = 2*pi*1i*f;

% 2. Noise
S_ref = 2 * 10^(-155/10); 
S_thermal = 2 * 10^(-120/10); 
sigma_t_ref = (1/(2*pi*f_dco)) * sqrt(S_ref * f_dco);
sigma_t_dco = (f_off/f_dco) * sqrt((S_thermal) / f_dco);

% 3. Phases
% Phase 1 [PLL tries to lock]
N_locking  = 10000;
% Phase 2 [PLL remain locked and the plots are extracted]
N_locked = 500000; 
N_total = N_locking + N_locked;
rng(1);   % same random values

% 4. Pre-allocated storage [for faster response]
t_ref = zeros(N_total, 1);        % REF edge timestamps
t_div = zeros(N_total, 1);        % Divider edge timestamps  
t_e = zeros(N_total, 1);          % time error 
D_in = zeros(N_total, 1);         % TDC output
D_out = zeros(N_total, 1);        % Loop filter output
OTW = zeros(N_total, 1);          % Oscillator code word
f_inst_dco = zeros(N_total, 1);   % Instantaneous DCO frequency
T_inst_dco = zeros(N_total, 1);   % Instantaneous DCO period
integral_sum = zeros(N_total, 1); % Integrator state (rho path)
O_TDC = zeros(N_total, 1);        % TDC output code

% 5. Timestamps produced by the DCO
% Store ALL CKV edges (transient + locked) for dense period/freq plots
CKV_all    = zeros(N_total * N, 1);
CKV_locked = zeros(N_locked * N, 1);

% 6. Build of the reference signal
for n = 1:N_total
    t_ref(n) = n * T_ref + sigma_t_ref * randn(1);
end

% 7. Initialization
OTW_init = Delta_F / K_dco; % code of the initial frequency offset
int_sum = 0;               % t=0, no error yet in the filter integrator
edge_ptr = 0;              % 0 indexing for CKV_all at t=0
t_ckv = 0;                 % 0 timestamps at t=0

% 8. Initializing the output of the divider
for n = 1:N
    edge_ptr = edge_ptr + 1;
    t_ckv = t_ckv + T_o + sigma_t_dco * randn(1) - K_T*OTW_init;
    CKV_all(edge_ptr) = t_ckv;
end
t_div(1) = t_ckv; % First divider output after 24 ref cycles.

%  7. Time model of the ADPLL
for k = 1:N_total

    % 7.1 Time error 
    t_e(k) = t_ref(k) - t_div(k);

    % 7.2 TDC quantisation 
    O_TDC(k) = round(t_e(k) / Delta_tres);

    % DCO period when the cycle arrives
    if k == 1
        TDCO = T_o - K_T*OTW_init;
    else
        TDCO = T_inst_dco(k-1);
    end
    D_in(k) = O_TDC(k) * (Delta_tres / TDCO);

    % 7.3 loop filter 
    int_sum  = int_sum + D_in(k);
    D_out(k) = alpha*D_in(k) + rho*int_sum;

    % 7.4 OTW
    OTW(k) = -(f_ref/K_dco) * D_out(k);

    % 7.5 instantaneous values of DCO
    f_inst_dco(k) = f_dco + K_dco*OTW(k);
    T_inst_dco(k) = T_o - K_T*OTW(k);

    % 7.6 Generation of the next DCO edges
    if k < N_total
        for n = 1:N
            edge_ptr = edge_ptr + 1;
            t_ckv    = t_ckv + T_o + sigma_t_dco * randn(1) - K_T * OTW(k);

            % Store ALL edges for dense plots
            if edge_ptr <= numel(CKV_all)
                CKV_all(edge_ptr) = t_ckv;
            end

            % Store locked section edges for phase noise
            if k >= N_locking
                locked_idx = (k - N_locking)*N + n;
                if locked_idx >= 1 && locked_idx <= numel(CKV_locked)
                    CKV_locked(locked_idx) = t_ckv;
                end
            end
        end
        t_div(k+1) = t_ckv;
    end

end
fprintf('Simulation complete.\n\n');

%=================================================
%  8. Transient quantities
%=================================================
t_us       = (1:N_total)' * T_ref * 1e6;
freq_dev   = f_inst_dco - f_dco;
phi_err_n  = t_e / T_ref;
period_dev = T_inst_dco - T_o;

% Dense frequency deviation
f_inst_from_tDIV = N ./ diff(t_div);
freq_dev_dense   = f_inst_from_tDIV - f_dco;
t_us_dense       = (1:N_total-1) * T_ref * 1e6;

% Dense period deviation
CKV_all_valid  = CKV_all(CKV_all > 0);
T_inst_ckv     = diff(CKV_all_valid);
T_dev_dense    = (T_inst_ckv - T_o) * 1e12;
t_ckv_us_dense = CKV_all_valid(1:end-1) * 1e6;

%=================================================
%  3(b): Transient plots
%=================================================

% Plot 1: Frequency deviation
figure('Color', 'w');
plot(t_us_dense, freq_dev_dense/1e6, 'r', 'LineWidth', 0.8);
hold on;
grid on;
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', ...
    'GridColor', 'k', 'MinorGridColor', 'k');
ylabel('\Delta f_{CKV} (MHz)');
title('Instantaneous Frequency Deviation', 'Color', 'k');
xlabel('Time (\mus)');
xlim([0 5]);

% Plot 2: Phase error
figure('Color', 'w');
plot(t_us, phi_err_n, 'b', 'LineWidth', 1);
hold on;
yline(0, 'k--', 'LineWidth', 0.8);
grid on;
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', ...
    'GridColor', 'k', 'MinorGridColor', 'k');
ylabel('\Phi_e[k] / 2\pi');
title('Instantaneous Phase Error', 'Color', 'k');
xlabel('Time (\mus)');
xlim([0 5]);

% Plot 3: Period deviation
figure('Color', 'w');
plot(t_ckv_us_dense, T_dev_dense, 'g', 'LineWidth', 0.5);
hold on;
yline(0, 'k--', 'LineWidth', 0.8);
grid on;
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', ...
    'GridColor', 'k', 'MinorGridColor', 'k');
xlabel('Time (\mus)');
ylabel('\Delta T_{CKV} (ps)');
title('Instantaneous Period Deviation', 'Color', 'k');
xlim([0 5]);

%=========================================================
%  PART 3(c): Phase noise — ADPLL simulated only
%=========================================================
valid     = CKV_locked > 0;
CKV_valid = CKV_locked(valid);
M         = numel(CKV_valid);
fprintf('Locked CKV edges available: %d\n', M);

if M > 1000

    % Timing error vs ideal grid
    n_idx   = (0:M-1)';
    t_ideal = CKV_valid(1) + n_idx * T_o;
    t_err   = CKV_valid - t_ideal;

    % Phase [rad]
    phi_rad = 2*pi * f_dco * t_err;

    % Welch PSD with Blackman-Harris window for smooth curve
    seg_len  = floor(M / 20);
    [Sphi, f_pn] = pwelch(phi_rad, blackmanharris(seg_len), [], [], f_dco, 'onesided');

    % L(f) = S_phi/2 [dBc/Hz]
    L_dBc = 10*log10(Sphi / 2);

    % Minimum reliable frequency — cut x-axis here to avoid unreliable region
    f_min_reliable = f_dco / M * 20;

    figure('Color', 'w');
    semilogx(f_pn, L_dBc, 'b-', 'LineWidth', 1.2, ...
        'DisplayName', 'ADPLL simulated');
    grid on;
    set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', ...
        'GridColor', 'k', 'MinorGridColor', 'k');
    xlabel('Offset frequency (Hz)');
    ylabel('L(f)  [dBc/Hz]');
    title('ADPLL output phase noise (locked)', 'Color', 'k');
    xlim([f_min_reliable, f_dco/2]);
    ylim([-175 -80]);

    %=========================================================
    %  PART 3(d): Integrated jitter
    %=========================================================
    f_lo = 10e3;
    f_hi = 40e6;

    mask      = f_pn >= f_lo & f_pn <= f_hi;
    J_rms_rad = sqrt(trapz(f_pn(mask), Sphi(mask)));
    J_rms_ps  = J_rms_rad / (2*pi*f_dco) * 1e12;

    fprintf('\n=== Integrated jitter  %.0f kHz - %.0f MHz ===\n', ...
        f_lo*1e-3, f_hi*1e-6);
    fprintf('  RMS phase  = %.4f rad\n', J_rms_rad);
    fprintf('  RMS jitter = %.3f ps\n',  J_rms_ps);

else
    warning('Not enough locked edges for phase noise computation.');
end

fprintf('\nAll done.\n');