# Created by Teng Xiang at 2018-08-10
# Current version: 2018-08-10 
# https://github.com/helianvine/fdndlp
# =============================================================================

import numpy as np
from numpy.lib import stride_tricks

def stft(data, frame_size=512, overlap=0.75, window=None):
    """ Multi-channel short time fourier transform 

    Args:
        data: A 2-dimension numpy array with shape=(channels, samples)
        frame_size: An integer number of the length of the frame
        overlap: A float nonnegative number less than 1 indicating the overlap
                 factor between adjacent frames

    Return:
        A 3-dimension numpy array with shape=(channels, frames, frequency_bins) 
    """
    assert(data.ndim == 2)
    if window == None:
        window = np.hanning(frame_size) 
    frame_shift = int(frame_size - np.floor(overlap * frame_size))
    cols = int(np.ceil((data.shape[1] - frame_size) / frame_shift)) + 1
    data = np.concatenate(
        (data, np.zeros((data.shape[0], frame_shift), dtype = np.float32)),
        axis = 1)
    samples = data.copy()
    frames = stride_tricks.as_strided(
        samples,
        shape=(samples.shape[0], cols, frame_size),
        strides=(
            samples.strides[-2], 
            samples.strides[-1] * frame_shift, 
            samples.strides[-1])).copy()
    frames *= window
    return np.fft.rfft(frames)

def istft(data, frame_size=None, overlap=0.75, window=None):
    """ Multi-channel inverse short time fourier transform

    Args:
        data: A 3-dimension numpy array with shape=(channels, frames, frequency_bins) 
        frame_size: An integer number of the length of the frame
        overlap: A float nonnegative number less than 1 indicating the overlap
                 factor between adjacent frames

    Return:
        A 2-dimension numpy array with shape=(channels, samples)
    """
    assert(data.ndim == 3)
    real_data = np.fft.irfft(data)
    if frame_size == None:
        frame_size = real_data.shape[-1]
    frame_num = data.shape[-2]
    frame_shift = int(frame_size - np.floor(frame_size * overlap))
    length = (frame_num - 1) * frame_shift + frame_size
    output = np.zeros((data.shape[0], length))
    for i in range(frame_num):
        index = i*frame_shift
        output[:, index : index + frame_size] += real_data[:,i]
    return output
    
def log_spectrum(raw_data, frame_length=512):
    """Log magnitude spectrogram"""
    if raw_data.ndim == 1:
        raw_data = np.reshape(raw_data, (1, -1))
    freq_data = stft(raw_data)
    phase = np.angle(freq_data)
    freq_data = np.abs(freq_data)
    freq_data = np.maximum(freq_data, 1e-8)
    log_data = np.log10(freq_data / freq_data.min())
    return log_data, phase
