__author__ = "Alvaro Joaquin Gaona"
__email__ = "alvgaona@gmail.com"

LMS Filtering

This script filters an ECG Signal.

s(n): ECG Signal
i(n): Interference Signal
v(n): White Gaussian Noise

d(n) = s(n) + i(n) + v(n)

The interference nature is assumed to be a tone of 60 Hz.

i(n) = Asin(omega*n + theta)

We also assume to have a reference signal.

r(n) = Bsin(omega*n)

