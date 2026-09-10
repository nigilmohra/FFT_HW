# 𝗖𝗢𝗠𝗕𝗜𝗡𝗘𝗗 𝟴-𝗣𝗣𝗧 𝗙𝗢𝗥𝗪𝗔𝗥𝗗 𝗔𝗡𝗗 𝗜𝗡𝗩𝗘𝗥𝗦𝗘 𝗙𝗔𝗦𝗧 𝗙𝗢𝗨𝗥𝗜𝗘𝗥 𝗧𝗥𝗔𝗡𝗦𝗙𝗢𝗥𝗠
This repository contains a 16-bit fixed-point Verilog implementation of a combined 8-point forward and inverse Fast Fourier Transform. The hardware uses the same module to perform both FFT and IFFT based on the relationship given in Equation 1. This work was carried out as part of my internship at IIT Delhi under the guidance of Prof. Kaushik Saha (EE) and Prof. Rakesh Kumar Palani (EE).

$$
X[k] = \sum_{n=0}^{N-1} x[n] \, e^{-j\frac{2\pi}{N}kn}, \qquad k = 0, 1, \dots, N-1
$$

$$
x[n] = \frac{1}{N}\sum_{k=0}^{N-1} X[k] \, e^{+j\frac{2\pi}{N}kn}, \qquad n = 0, 1, \dots, N-1
$$

$$
W_N^{k} = e^{-j\frac{2\pi}{N}k}
$$

\begin{equation}
X[k] = \sum_{n=0}^{N/2-1} x[2n]\, W_N^{2nk} \;+\; W_N^{k}\sum_{n=0}^{N/2-1} x[2n+1]\, W_N^{2nk} \;=\; E[k] + W_N^{k}\,O[k]
\label{eq:radix2}
\end{equation}
