# MATLAB and Simulink Labwork (IYTE EEE)

Laboratory work, homework and simulations in MATLAB and Simulink for the Signals and Systems, Analog Communications and control courses at the Department of Electrical and Electronics Engineering, İzmir Institute of Technology.

## Contents

| Folder | Course | What is inside | Status |
|---|---|---|---|
| [`Analog_Communications_Labs/`](Analog_Communications_Labs/README.md) | Analog Communications | Lab scripts on signals, conventional AM, DSB-SC, VSB/SSB, FM and PM | 🟡 Labs 1, 2, 5 and 6 added; 3 and 4 pending |
| [`HW_Signals_and_Sytems/`](HW_Signals_and_Sytems/README.md) | EE331 Signals and Systems | Spectral analysis of a recorded musical note sequence, band-pass filter design and an App Designer GUI | ✅ Added |
| [`PID Controller Design and Simulation/`](PID%20Controller%20Design%20and%20Simulation/README.md) | CENG 424 | PID tuning for servo motor position control in Simulink | ✅ Added |

## Analog Communications labs

| Lab | Topic | Script |
|---|---|---|
| 1 | Signals and systems | [`lab1halil.m`](Analog_Communications_Labs/Lab1/lab1halil.m) |
| 2 | Conventional AM | [`lab2halilyilmaz.m`](Analog_Communications_Labs/Lab2_Conventional_AM/lab2halilyilmaz.m) |
| 3 | DSB-SC | not added yet |
| 4 | VSB/SSB | not added yet |
| 5 | FM | [`lab5_HalilYilmaz.m`](Analog_Communications_Labs/Lab5_FM/lab5_HalilYilmaz.m) |
| 6 | PM | [`lab6halilyilmaz.m`](Analog_Communications_Labs/Lab6_PM/lab6halilyilmaz.m) |

Labs 7 (AM in noise) and 8 (FM in noise) are on the course schedule but not in this repository yet.

## Running

Open the `.m` file of the lab or homework in MATLAB and run it section by section (`%%` blocks). The homework script reads `signal.mp4` from its own folder. The Simulink models are the `.slx` files in the PID folder.

## Requirements

- MATLAB (App Designer for the `.mlapp` GUI in `HW_Signals_and_Sytems/`)
- Simulink (PID folder only; the tuning example may need Simulink Control Design)
