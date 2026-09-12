# ===========================================================================
# TEST-BENCH FOR FFT/IFFT HARDWARE ACCELERATOR (CombinedFFT16b.v)
# ===========================================================================
# Author : Nigil M R

import random

import cocotb
from cocotb.triggers import Timer
import numpy as np

N       = 8      # FFT/IFFT Point Size
NUM_VEC = 100    # Number of Test Vectors
TOL     = 5.0    # LSB Tolerance

# Test Vectors
inVec      = [None] * NUM_VEC
expFFTOut  = [None] * NUM_VEC
expIFFTOut = [None] * NUM_VEC

# Variables
passCount = {0: 0, 1: 0}   # MODE: 0 = FFT, 1 = IFFT
failCount = {0: 0, 1: 0}
count_i   = 0

# Sign Extend Output
def toSigned16(value):
    value = int(value) & 0xFFFF
    return value - 0x10000 if value & 0x8000 else value

# Load Vectors
def loadVectors():
    rng = random.Random(12345)
    for v in range(NUM_VEC):
        x = np.array([complex(rng.randint(-2000, 2000), rng.randint(-2000, 2000)) for n in range(N)])
        inVec[v]      = x
        expFFTOut[v]  = np.fft.fft(x)
        expIFFTOut[v] = np.fft.ifft(x)

# Drive Inputs
def driveInputs(dut, x):
    dut.realIn_00.value = int(x[0].real); dut.imagIn_00.value = int(x[0].imag)
    dut.realIn_01.value = int(x[1].real); dut.imagIn_01.value = int(x[1].imag)
    dut.realIn_02.value = int(x[2].real); dut.imagIn_02.value = int(x[2].imag)
    dut.realIn_03.value = int(x[3].real); dut.imagIn_03.value = int(x[3].imag)
    dut.realIn_04.value = int(x[4].real); dut.imagIn_04.value = int(x[4].imag)
    dut.realIn_05.value = int(x[5].real); dut.imagIn_05.value = int(x[5].imag)
    dut.realIn_06.value = int(x[6].real); dut.imagIn_06.value = int(x[6].imag)
    dut.realIn_07.value = int(x[7].real); dut.imagIn_07.value = int(x[7].imag)


# Read Outputs
def readOutputs(dut):
    return [
        complex(toSigned16(dut.realOut_00.value), toSigned16(dut.imagOut_00.value)),
        complex(toSigned16(dut.realOut_01.value), toSigned16(dut.imagOut_01.value)),
        complex(toSigned16(dut.realOut_02.value), toSigned16(dut.imagOut_02.value)),
        complex(toSigned16(dut.realOut_03.value), toSigned16(dut.imagOut_03.value)),
        complex(toSigned16(dut.realOut_04.value), toSigned16(dut.imagOut_04.value)),
        complex(toSigned16(dut.realOut_05.value), toSigned16(dut.imagOut_05.value)),
        complex(toSigned16(dut.realOut_06.value), toSigned16(dut.imagOut_06.value)),
        complex(toSigned16(dut.realOut_07.value), toSigned16(dut.imagOut_07.value)),
    ]

# Run Vector
async def runVector(dut, idx, mode):
    dut.MODE.value = mode
    driveInputs(dut, inVec[idx])
    await Timer(1, unit="ns")
    rtlOut = readOutputs(dut)

    expOut = expFFTOut[idx] if mode == 0 else expIFFTOut[idx]
    err = max(max(abs(rtlOut[k].real - expOut[k].real), abs(rtlOut[k].imag - expOut[k].imag)) for k in range(N))

    if err <= TOL:
        passCount[mode] = passCount[mode] + 1
    else:
        failCount[mode] = failCount[mode] + 1

# Main
@cocotb.test()
async def testModule(dut):
    global count_i

    loadVectors()

    for mode in (0, 1):
        for count_i in range(NUM_VEC):
            await runVector(dut, count_i, mode)

    dut._log.info("CombinedFFT16b")
    dut._log.info(f"FFT : {passCount[0]}/{NUM_VEC} Passed")
    dut._log.info(f"IFFT: {passCount[1]}/{NUM_VEC} Passed")

    assert failCount[0] == 0, f"FFT : {failCount[0]} Failures"
    assert failCount[1] == 0, f"IFFT: {failCount[1]} Failures"

# Run Test
if __name__ == "__main__":
    from cocotb_tools.runner import get_runner

    runner = get_runner("verilator")
    runner.build(
        sources=["CombinedFFT16b.v"],
        hdl_toplevel="CombinedFFT16b",
        always=True,
    )
    runner.test(
        hdl_toplevel="CombinedFFT16b",
        test_module="CombinedFFT16b_tb",
    )
