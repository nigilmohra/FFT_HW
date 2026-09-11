// ===========================================================================
// TEST-BENCH FOR FFT/IFFT HARDWARE ACCELERATOR (CombinedFFT16b.v)
// ===========================================================================
// Author : Nigil M R

#include "VCombinedFFT16b.h"
#include "verilated.h"

#include <cmath>
#include <complex>
#include <cstdint>
#include <cstdio>
#include <random>
#include <vector>

typedef std::complex<double> cplx;

// FFT/IFFT Point Size
static const int N = 8;    
// Number of Test Vectors
static const int NUM_VEC = 100; 

// Device Under Test
VCombinedFFT16b* DUT;

// Variables
int passCountFFT, failCountFFT;
int passCountIFFT, failCountIFFT;
int count_i;

// Test Vectors
cplx inVec         [NUM_VEC][N];
cplx expFFTOut     [NUM_VEC][N];
cplx expIFFTOut    [NUM_VEC][N];

// Golden Reference
static void computeDFT(const cplx x[N], cplx X[N], bool inverse) {
    double sign = inverse ? 1.0 : -1.0;
    for (int k = 0; k < N; k++) {
        cplx sum(0.0, 0.0);
        for (int n = 0; n < N; n++) {
            double angle = sign * 2.0 * M_PI * k * n / N;
            sum += x[n] * cplx(std::cos(angle), std::sin(angle));
        }
        X[k] = inverse ? sum / double(N) : sum;
    }
}

// Load Vectors
static void loadVectors() {
    std::mt19937 rng(12345);
    std::uniform_int_distribution<int> dist(-2000, 2000);

    for (int v = 0; v < NUM_VEC; v++) {
        for (int n = 0; n < N; n++)
            inVec[v][n] = cplx(dist(rng), dist(rng));
        computeDFT(inVec[v], expFFTOut[v],  false);
        computeDFT(inVec[v], expIFFTOut[v], true);
    }
}

static const double TOL = 5.0;  // LSB Tolerance

// Run FFT Vector
static void runVectorFFT(int idx) {
    DUT->MODE = 0;
    DUT->realIn_00 = (int16_t)std::lround(inVec[idx][0].real()); DUT->imagIn_00 = (int16_t)std::lround(inVec[idx][0].imag());
    DUT->realIn_01 = (int16_t)std::lround(inVec[idx][1].real()); DUT->imagIn_01 = (int16_t)std::lround(inVec[idx][1].imag());
    DUT->realIn_02 = (int16_t)std::lround(inVec[idx][2].real()); DUT->imagIn_02 = (int16_t)std::lround(inVec[idx][2].imag());
    DUT->realIn_03 = (int16_t)std::lround(inVec[idx][3].real()); DUT->imagIn_03 = (int16_t)std::lround(inVec[idx][3].imag());
    DUT->realIn_04 = (int16_t)std::lround(inVec[idx][4].real()); DUT->imagIn_04 = (int16_t)std::lround(inVec[idx][4].imag());
    DUT->realIn_05 = (int16_t)std::lround(inVec[idx][5].real()); DUT->imagIn_05 = (int16_t)std::lround(inVec[idx][5].imag());
    DUT->realIn_06 = (int16_t)std::lround(inVec[idx][6].real()); DUT->imagIn_06 = (int16_t)std::lround(inVec[idx][6].imag());
    DUT->realIn_07 = (int16_t)std::lround(inVec[idx][7].real()); DUT->imagIn_07 = (int16_t)std::lround(inVec[idx][7].imag());
    DUT->eval();

    cplx rtlOut[N] = {
        cplx((int16_t)DUT->realOut_00, (int16_t)DUT->imagOut_00),
        cplx((int16_t)DUT->realOut_01, (int16_t)DUT->imagOut_01),
        cplx((int16_t)DUT->realOut_02, (int16_t)DUT->imagOut_02),
        cplx((int16_t)DUT->realOut_03, (int16_t)DUT->imagOut_03),
        cplx((int16_t)DUT->realOut_04, (int16_t)DUT->imagOut_04),
        cplx((int16_t)DUT->realOut_05, (int16_t)DUT->imagOut_05),
        cplx((int16_t)DUT->realOut_06, (int16_t)DUT->imagOut_06),
        cplx((int16_t)DUT->realOut_07, (int16_t)DUT->imagOut_07)
    };

    bool ok = true;
    for (int k = 0; k < N; k++) {
        double err = std::max(std::abs(rtlOut[k].real() - expFFTOut[idx][k].real()),
                               std::abs(rtlOut[k].imag() - expFFTOut[idx][k].imag()));
        if (err > TOL) ok = false;
    }

    if (ok) passCountFFT = passCountFFT + 1;
    else    failCountFFT = failCountFFT + 1;
}

// Run IFFT Vector
static void runVectorIFFT(int idx) {
    DUT->MODE = 1;
    DUT->realIn_00 = (int16_t)std::lround(inVec[idx][0].real()); DUT->imagIn_00 = (int16_t)std::lround(inVec[idx][0].imag());
    DUT->realIn_01 = (int16_t)std::lround(inVec[idx][1].real()); DUT->imagIn_01 = (int16_t)std::lround(inVec[idx][1].imag());
    DUT->realIn_02 = (int16_t)std::lround(inVec[idx][2].real()); DUT->imagIn_02 = (int16_t)std::lround(inVec[idx][2].imag());
    DUT->realIn_03 = (int16_t)std::lround(inVec[idx][3].real()); DUT->imagIn_03 = (int16_t)std::lround(inVec[idx][3].imag());
    DUT->realIn_04 = (int16_t)std::lround(inVec[idx][4].real()); DUT->imagIn_04 = (int16_t)std::lround(inVec[idx][4].imag());
    DUT->realIn_05 = (int16_t)std::lround(inVec[idx][5].real()); DUT->imagIn_05 = (int16_t)std::lround(inVec[idx][5].imag());
    DUT->realIn_06 = (int16_t)std::lround(inVec[idx][6].real()); DUT->imagIn_06 = (int16_t)std::lround(inVec[idx][6].imag());
    DUT->realIn_07 = (int16_t)std::lround(inVec[idx][7].real()); DUT->imagIn_07 = (int16_t)std::lround(inVec[idx][7].imag());
    DUT->eval();

    cplx rtlOut[N] = {
        cplx((int16_t)DUT->realOut_00, (int16_t)DUT->imagOut_00),
        cplx((int16_t)DUT->realOut_01, (int16_t)DUT->imagOut_01),
        cplx((int16_t)DUT->realOut_02, (int16_t)DUT->imagOut_02),
        cplx((int16_t)DUT->realOut_03, (int16_t)DUT->imagOut_03),
        cplx((int16_t)DUT->realOut_04, (int16_t)DUT->imagOut_04),
        cplx((int16_t)DUT->realOut_05, (int16_t)DUT->imagOut_05),
        cplx((int16_t)DUT->realOut_06, (int16_t)DUT->imagOut_06),
        cplx((int16_t)DUT->realOut_07, (int16_t)DUT->imagOut_07)
    };

    bool ok = true;
    for (int k = 0; k < N; k++) {
        double err = std::max(std::abs(rtlOut[k].real() - expIFFTOut[idx][k].real()),
                               std::abs(rtlOut[k].imag() - expIFFTOut[idx][k].imag()));
        if (err > TOL) ok = false;
    }

    if (ok) passCountIFFT = passCountIFFT + 1;
    else    failCountIFFT = failCountIFFT + 1;
}

// Main
int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    DUT = new VCombinedFFT16b;

    passCountFFT  = 0; failCountFFT  = 0;
    passCountIFFT = 0; failCountIFFT = 0;

    loadVectors();

    for (count_i = 0; count_i < NUM_VEC; count_i = count_i + 1)
        runVectorFFT(count_i);

    for (count_i = 0; count_i < NUM_VEC; count_i = count_i + 1)
        runVectorIFFT(count_i);

    printf("CombinedFFT16b\n");
    printf("FFT : %d/%d passed\n",  passCountFFT,  NUM_VEC);
    printf("IFFT: %d/%d passed\n",  passCountIFFT, NUM_VEC);

    delete DUT;
    return (failCountFFT == 0 && failCountIFFT == 0) ? 0 : 1;
}
