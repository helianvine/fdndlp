# Created by Teng Xiang at 2018-08-10
# Current version: 2018-08-10 
# https://github.com/helianvine/fdndlp
# =============================================================================

""" Weighted prediction error(WPE) method for speech dereverberation."""

import stft
import argparse
import librosa
import time
import numpy as np
from numpy.lib import stride_tricks
import matplotlib.pyplot as plt

class Configrations():
    """Argument parser for WPE method configurations."""
    def __init__(self):
        self.parser = argparse.ArgumentParser()

    def parse(self):
        self.parser.add_argument(
            '-m', '--mic_num', type=int, default=3,
            help='number of input channels')
        self.parser.add_argument(
            '-n','--out_num', type=int, default=2,
            help='number of output channels')
        self.parser.add_argument(
            '-p', '--order', type=int, default=30,
            help='predition order')
        self.cfgs = self.parser.parse_args()
        return self.cfgs


class WpeMethod(object):
    """WPE metheod for speech dereverberaiton 

    Weighted prediction errors (WPE) method is an outstanding speech 
    derverberation algorithm, which is based on the multi-channel linear
    prediction algorithm and produces multi-channel output.

    Attributes:
        channels: Number of input channels.
        out_num: Number of output channels.
        p: An integer number of the prediction order.
        d: An integer number of the prediction delay.
        frame_size: An integer number of the length of the frame
        overlap: A float nonnegative number less than 1 indicating the overlap
                 factor between adjacent frames
    """
    def __init__(self, mic_num, out_num, order=30):
        self.channels = mic_num
        self.out_num = out_num
        self.p = order
        self.d = 2
        self.frame_size = 512
        self.overlap = 0.5
        self._iterations = 2
    
    @property
    def iterations(self):
        return self._iterations

    @iterations.setter
    def iterations(self, value):
        assert(int(value) > 0)
        self._iterations = int(value)

    def _display_cfgs(self):
        print("Input channels: %d" % self.channels)
        print("Output channels: %d" % self.out_num)
        print("Prediction order: %d" % self.p)


    def run_offline(self, data):
        self._display_cfgs()
        time_start = time.time()
        print("Processing...")
        drv_data = self.__fdndlp(data)
        print("Done!\nTotal time: %f\n" % (time.time() - time_start))
        return drv_data

    def __fdndlp(self, data):
        """Frequency-domain variance-normalized delayed liner prediction 

        This is the core part of the WPE method. The variance-normalized 
        linear prediciton algorithm is implemented in each frequency bin 
        separately. Both the input and output signals are in time-domain.  

        Args:
            data: A 2-dimension numpy array with shape=(chanels, samples)

        Returns:
            A 2-dimension numpy array with shape=(output_channels, samples)
        """

        freq_data = stft.stft(
            data / np.abs(data).max(), 
            frame_size=self.frame_size, overlap=self.overlap)
        self.freq_num = freq_data.shape[-1]
        drv_freq_data = freq_data[0:self.out_num].copy()
        for i in range(self.freq_num):
            xk = freq_data[:,:,i].T
            dk = self.__ndlp(xk)
            drv_freq_data[:,:,i] = dk.T
        drv_data = stft.istft(
            drv_freq_data, 
            frame_size=self.frame_size, overlap=self.overlap)
        return drv_data / drv_data.max()


    def __ndlp(self, xk):
        """Variance-normalized delayed liner prediction 

        Here is the specific WPE algorithm implementation. The input should be
        the reverberant time-frequency signal in a single frequency bin and 
        the output will be the dereverberated signal in the corresponding 
        frequency bin.

        Args:
            xk: A 2-dimension numpy array with shape=(frames, input_chanels)

        Returns:
            A 2-dimension numpy array with shape=(frames, output_channels)
        """
        cols = xk.shape[0] - self.d
        xk_buf = xk[:,0:self.out_num]
        xk = np.concatenate(
            (np.zeros((self.p - 1, self.channels)), xk),
            axis=0)
        xk_tmp = xk[:,::-1].copy()
        frames = stride_tricks.as_strided(
            xk_tmp,
            shape=(self.channels * self.p, cols),
            strides=(xk_tmp.strides[-1], xk_tmp.strides[-1]*self.channels))
        frames = frames[::-1]
        sigma2 = np.mean(1 / (np.abs(xk_buf[self.d:]) ** 2), axis=1)
        for _ in range(self.iterations):
            x_cor_m = np.dot(
                    np.dot(frames, np.diag(sigma2)),
                    np.conj(frames.T))
            x_cor_v = np.dot(
                frames, 
                np.conj(xk_buf[self.d:] * sigma2.reshape(-1, 1)))
            coeffs = np.dot(np.linalg.inv(x_cor_m), x_cor_v)
            dk = xk_buf[self.d:] - np.dot(frames.T, np.conj(coeffs))
            sigma2 = np.mean(1 / (np.abs(dk) ** 2), axis=1)
        return np.concatenate((xk_buf[0:self.d], dk))

    def load_audio(self, filename):
        data, _ = librosa.load(filename, sr=None, mono=False)
        assert(data.shape[0] >= self.channels)
        if data.shape[0] > self.channels:
            print(
                "The number of the input channels is %d," % data.shape[0],
                "and only the first %d channels are loaded." % self.channels)
            data = data[0: self.channels]
        return data

if __name__ == '__main__':
    filename = '../wav_sample/sample_4ch.wav'
    cfgs = Configrations().parse()
    wpe = WpeMethod(cfgs.mic_num, cfgs.out_num, cfgs.order)
    data = wpe.load_audio(filename)
    drv_data = wpe.run_offline(data)

    # plt.figure()
    # spec, _ = stft.log_spectrum(drv_data[0])
    # plt.pcolor(spec[0].T)
    # plt.show()