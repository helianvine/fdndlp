function y = fdndlp(x, cfgs, varargin)
%
% ============================================================================= 
%
% This program is an implementation of Variance-Normalizied Delayed Linear
% Prediction in time-frequency domain, which is aimed at speech
% dereverberation, known as weighted prediction error (WPE) method.
% 
% Main parameters:
% mic_num                  the number of channels
% K                        the number of subbands
% F                        over-sampling rate
% N                        decimation factor
% D1                       subband preditction delay
% Lc1                      subband prediction order 
% eps                      lower bound of normalizaton factor
%
% Reference:
% [1] Nakatani T, Yoshioka T, Kinoshita K, et al. Speech Dereverberation 
%     Based on Variance-Normalized Delayed Linear Prediction[J]. IEEE 
%     Transactions on Audio Speech & Language Processing, 2010, 18(7):1717-1731.
%
% ============================================================================= 
% Created by Teng Xiang at 2017-10-14 
% Current version: 2018-08-10
% ============================================================================= 


% ============================================================================= 
% Load Parameters
% ============================================================================= 
if ischar(cfgs)
    run(cfgs);
else
    varnames = fieldnames(cfgs);
    for ii = 1 : length(varnames)
        eval([varnames{ii}, '= getfield(cfgs, varnames{ii});']);
    end 
end

if exist('varargin', 'var')
    for ii = 1 : 2 : length(varargin)
        eval([varargin{ii}, '= varargin{ii+1};'])
    end
end

len = length(x);

% ============================================================================= 
% Frequency-domain variance-normalized delayed linear prediction
% ============================================================================= 
sig_channels = size(x, 2);
if sig_channels > num_mic
   x = x(:,1:num_mic);
   fprintf('Only the first %d channels of input data are used\n\n', num_mic)
elseif sig_channels < num_mic
    error('The channels of input does not match the channel setting');        
end

tic
fprintf('Procssing...')

xk = stftanalysis(x / max(max(abs(x))), K, N);
LEN = size(xk, 1);
dk = zeros(LEN, K, num_out);

for k = 1 : K/2 + 1
    xk_tmp = zeros(LEN+Lc1, num_mic);
    xk_tmp(Lc1+1:end,:) = squeeze(xk(:,k,:));
    xk_tmp = xk_tmp.';
    x_buf = xk_tmp(1:num_out,Lc1+1:end).';
    X_BUF = zeros(num_mic * Lc1, LEN);
    for ii = 1 : LEN-D1
        xn_D = xk_tmp(:,ii+Lc1:-1:ii+1);
        X_BUF(:,ii+D1) = xn_D(:); 
    end 
    rho2 = max(mean(abs(x_buf(:,1:num_out)).^2, 2), eps);
    c_Err = max_iterations;

    while (c_Err > 1e-2)
        Lambda = diag(1 ./ rho2);
        Phi = X_BUF*Lambda*X_BUF';
        p = X_BUF*conj(x_buf./rho2(:,ones(1,num_out)));
        c = pinv(Phi)*p;
        dk(:,k,:) = (x_buf.' - c'*X_BUF).';
        rho2 = max(mean(squeeze(abs(dk(:,k,:)).^2),2), eps);
        c_Err = c_Err - 1;
    end
end
dk(:,K/2+2:end,:) = conj(dk(:,K/2:-1:2,:));
y = stftsynthesis(dk, K, N);
y = y(1 : len, :) / max(max(abs(y)));
disp('Done!')
toc
