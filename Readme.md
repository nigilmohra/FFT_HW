# 𝗖𝗢𝗠𝗕𝗜𝗡𝗘𝗗 𝟴-𝗣𝗣𝗧 𝗙𝗢𝗥𝗪𝗔𝗥𝗗 𝗔𝗡𝗗 𝗜𝗡𝗩𝗘𝗥𝗦𝗘 𝗙𝗔𝗦𝗧 𝗙𝗢𝗨𝗥𝗜𝗘𝗥 𝗧𝗥𝗔𝗡𝗦𝗙𝗢𝗥𝗠
This repository contains a 16-bit fixed-point Verilog implementation of a combined 8-point forward and inverse Fast Fourier Transform. The hardware uses the same module to perform both FFT and IFFT based on the relationship given in the Equation. The design has a tolerance of up to 5 LSB. The maximum error observed was approximately 2.5 to 2.6 LSB across 100 test cases for both FFT and IFFT. 

|<img width="1920" height="1040" alt="image" src="https://github.com/user-attachments/assets/342b0cb5-d7fe-4782-83e8-1dde6a12c5ce" />|
|:------:|
| _Figure 1. Successful Execution of 8-PPT Combined Forward and Inverse FFT Using Verilator_ |

**This work was carried out as part of my internship at the Indian Institute of Technology Delhi (IIT Delhi), under the guidance and supervision of Prof. Kaushik Saha (Department of Electrical Engineering) and Prof. Rakesh Kumar Palani (Department of Electrical Engineering)**.
