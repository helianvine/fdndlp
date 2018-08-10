clc;
clear;
close all;

% *****************************************************
% Set path
% *****************************************************

addpath(genpath('lib'));
output_dir = 'wav_out/';
if ~exist(output_dir, 'dir')
   mkdir(output_dir); 
   disp(['mkdir ', output_dir])
end

%******************************************************
% Input and Output Configurations 
%******************************************************

filepath = '../wav_sample/';
sample_name = 'sample_4ch.wav';
file_name = [filepath, sample_name];
out_name = [output_dir, ['drv_', sample_name]];

%******************************************************
% Set Parameters
%******************************************************
% cfgs.num_mic = 3;
% cfgs.num_out = 2;
% cfgs.K = 512;                               % the number of subbands
% cfgs.F = 2;                                 % over-sampling rate
% cfgs.N = cfg.K / cfg.F;                     % decimation factor
% cfgs.D1 = 2;                                % subband preditction delay                     
% cfgs.Lc1 = 30;                              % subband prediction order 
% cfgs.eps = 1e-4;                            % lower bound of rho(Normalizaton factor)
% cfgs.iterations = 2;

cfgs = 'config.m';


%******************************************************
% Read Audio Files and Processing
%******************************************************
sig_multi_mode = 1;
% sig_multi_mode = 0;
% sig_num_mic = 3;
disp('Reading Audio Files:')
if sig_multi_mode
    disp(file_name)
    [x, fs] = audioread(file_name);
else
    x = [];
    for m = 1 : sig_num_mic
        disp(file_name)
        filename1 = strrep(file_name, 'ch1', ['ch',num2str(m)]);
        [s, fs] = audioread(filename1);
        x = [x, s];
    end
end

y = fdndlp(x, cfgs);

% ***************************************************
% Output
% ***************************************************

util.fig(x(:,1), fs);
util.fig(y(:,1), fs);
% udf.play(x(:,1), fs);
% udf.play(y(:,1), fs);
disp(['write to file:',32, out_name])
audiowrite(out_name, y/max(max(abs(y))), fs);

rmpath(genpath('lib'));

