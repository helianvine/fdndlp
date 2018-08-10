
num_mic = 3;
num_out = 2;
K = 512;                               % the number of subbands
F = 2;                                 % over-sampling rate
N = K / F;                             % decimation factor
D1 = 2;                                % subband preditction delay                     
Lc1 = 30;                              % subband prediction order 
eps = 1e-4;                            % lower bound of rho(Normalizaton factor)
max_iterations = 2;