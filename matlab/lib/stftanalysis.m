
function y = stftanalysis(s, winsize, winshift)
%
%STFTANALYSIS short time Fourier transform analysis 
%  Decompose the time domain signal into the time-frequency domain signal  
%
%  y = STFTANALYSIS(s, winsize, winshift)
%
%  s is the time domain signal. If s is a matrix, the column of the matrix 
%  will be treated a vector and the analysis will be performed on the vectors
%  separately.
%  y is the time-frequency signal. If number of channels equals to 1, the 
%  the return value y will be a 2-D matrix (frame_number x window_size).
%  If the number of channels is more than 1, y will be a 3-D matrix 
%  (frame_number x window_size x channel_number)

% ============================================================================= 
% Created by Teng Xiang at 2018-01-12
% ============================================================================= 

win = hann(winsize);
channel_num = size(s, 2);
frame_num = ceil((size(s, 1) - winsize)/ winshift) + 1;
s = [s; zeros(winshift - mod(length(s) - winsize, winshift), channel_num)];
y = zeros(frame_num, winsize, channel_num);

for l = 1 : frame_num
    index = (l-1) * winshift;
    y(l,:,:) = reshape(...
        fft(bsxfun(@times, s(index + 1:index+winsize, :), win)),...
        1, winsize, channel_num);
end
