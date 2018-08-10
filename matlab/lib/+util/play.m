function player = play(varargin)

if ischar(varargin{1})
    [data, fs] = audioread(varargin{1});
    if length(varargin) == 1
       normalizemode  = 1; 
    else
       normalizemode = varargin{2};
    end
else
    
    data = varargin{1};
    fs = varargin{2};
    if length(varargin) == 2
       normalizemode = 1; 
    else
       normalizemode = varargin{3};
    end
end
if normalizemode
    data = data / max(abs(data)); 
end
player = audioplayer(data, fs);
play(player)