function fig(data_in,  fs)

if nargin == 1
    [data, fs] = audioread(data_in);
    filename = data_in;
else
    data = data_in;
end
Fs = 8000;
noverlap = 128 * fs / Fs;
nfft= 256 * fs / Fs;

figure;
spectrogram(data/max(abs(data)), hamming(nfft),noverlap,nfft,fs,'yaxis')
set(gcf, 'position', [1, 235, 1366, 400]);
set(gca, 'position', [0.05, 0.12, 0.85, 0.8]);
if exist('filename','var')
    title(filename, 'interpreter', 'none');
end

