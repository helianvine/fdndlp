# Frequency Domain Variance-normalized Delayed Linear Prediction Algorithm

## Introduction
This program is an implementation of variance-normalizied delayed linear prediction in time-frequency domain, which is aimed at speech dereverberation, known as weighted prediction error (WPE) method.


## Requirements
- MATLB Code
  - signal processing toolbox
- Python Code
  - Python 3.x
  - Numpy
  - soundfile
  - matplotlib (Optional) 

## Run the Demo
- MATLAB code
  - Just run the script file `demo_fdndlp.m` in MATLAB and the audio sample in `wav_sample` will be used.
  - To use your own data, change the `filepath` and `sample_name` in `demo_fdndlp.m`.
  - The configrations are gathered in `config.m`. Be careful to change the settings.

- Python code

  - Usage:
    ```bash
    python wpe.py [-h] [-o OUTPUT] [-m MIC_NUM] [-n OUT_NUM] [-p ORDER] filename
    ```
  - To use the default configrations and the given audio sample, run:
    ```bash
    python wpe.py ../wav_sample/sample_4ch.wav
    ```

## Layout
```
 ./
 +-- matlab/                          matlab code files
 |   +-- lib/
 |   |   +-- +util/                   utility functions
 |   |   |-- stftanalysis.m           
 |   |   |-- stftsynthesis.m
 |   |-- demo_fdndlp.m
 |   |-- fdndlp.m
 |   |-- config.m
 +-- python/                          python code files
 |   |-- wpe.py
 |   |-- stft.py
 +-- wav_sample/                      audio samples
 |   |-- sample_4ch.wav               reverberant speech
 |   |-- drv_sample_4ch.wav           dereverberated speech
 |-- README.md
```


## Reference

[WPE speech dereverberation](http://www.kecl.ntt.co.jp/icl/signal/wpe/)

 Nakatani T, Yoshioka T, Kinoshita K, et al. Speech Dereverberation Based on Variance-Normalized Delayed Linear Prediction[J]. IEEE Transactions on Audio Speech & Language Processing, 2010, 18(7):1717-1731.
