/**
 * This isn't used with the RV32I CPU,
 * it is just for learning purposes.
 *
 * Sources:
    * https://people.engr.tamu.edu/spalermo/ecen620/lecture07_ee620_phase_detectors.pdf
    * https://www.allaboutcircuits.com/technical-articles/introduction-to-phase-frequency-detectors/
 *
 * Takes in a reference signal.
 * Goes through a Phase Detector that will:
    * Compare the phase and the frequency reference input (fin),
    * with the feedback provided from the oscillator(or a clock in a simulation).
    * Which will output an error signal based on the phase/frequency difference

 * Which is fed into a Loop Filter that will:
    * Filter out the high-frequency noise, sum-frequency components,
    * and rapid error fluctuations from the phase detector,
    * turning the error signal into

 * Then is fed into a VCO that will:
    *

 * Which is fed back into the Phase Detector,
 * and generates an output:
    *
 */
