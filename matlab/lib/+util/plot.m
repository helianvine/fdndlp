function handle = plot(data_in, fs)
% 1) plotwav(data)
%    data is the wav filename including path
% 2) plotwav(data, fs)

if nargin == 1
    [data, fs] = audioread(data_in);
else
    data = data_in;
end
if nargout == 1
    handle = figure;
else
    figure;
end
plot((0 : length(data) - 1) / fs, data);
xlim([0 , (length(data) / fs)]);
xlabel('Time(Secs)')