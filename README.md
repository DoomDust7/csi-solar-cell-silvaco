# Crystalline-silicon solar cell — Silvaco Victory Device decks

Simulation decks and batch scripts for optimising an n+pp+ / p+nn+ crystalline-silicon solar cell with Silvaco TCAD (Victory Device), run on [nanoHUB](https://nanohub.org/tools/silvacotcad).

## Files
| File | Purpose |
|---|---|
| `Solar_Cell_FIXED.in` | The starting deck, with the spectral-response section fixed. The original deck never ran a wavelength sweep, so the IQE/EQE extraction failed. This version re-applies the material, model and method statements after reloading the structure, defines beam 2 after `solve init`, and sweeps it with `solve b2=1 beam=2 lambda1=0.30 wstep=0.02 wfinal=1.20`. |
| `Solar_Cell_FIXED_v2.in` | Same deck, but the two bias-sweep steps are `set` variables (`Vstep_dark`, `Vstep_light`). That lets a p+nn+ cell be swept at negative anode bias. With the default values it gives results identical to `Solar_Cell_FIXED.in` (verified). |
| `AM15G_ATLAS_POWER.spec` | AM1.5G spectrum read by the deck (`POWER.FILE`). It integrates to 100 mW/cm². |
| `AM15G.dat` | Same spectrum in the original file format. |
| `run1.sh` | Runs one case. It copies a deck, changes **only its `set` lines**, runs `deckbuild -run`, and appends Jsc/Voc/FF/η to `summary.txt`. |
| `queue.sh` | Runs a list of cases, at most 5 at a time (the nanoHUB session has a 2 GB memory limit). |

## Usage (nanoHUB → Silvaco TCAD → XTerm, in the folder holding these files)
```bash
# one case (n+pp+, original deck)
./run1.sh baseline "Absorber_thick=200 Dop_absorber=5e16"

# a list of cases: one per line, NAME|set overrides
printf 'Wp100|Absorber_thick=100\nWp200|Absorber_thick=200\n' > list.txt
./queue.sh list.txt

# p+nn+ needs the v2 deck and a negative sweep
DECK=Solar_Cell_FIXED_v2.in ./run1.sh pnn 'Emitter="p.type" Absorber="n.type" BSF="n.type" Va_max=-0.8 Vstep_dark=-0.01 Vstep_light=0.01'
```
Each case writes to `runs/<NAME>/` (deck, output, J-V logs, IQE/EQE/EQE2 `.dat`). For p+nn+ cells, Voc and FF print as negative numbers because of the sign convention; read them as magnitudes.

## Optimised design (18.85 %; the starting deck gives 14.34 %)
```bash
DECK=Solar_Cell_FIXED_v2.in ./run1.sh final 'Emitter="p.type" Absorber="n.type" BSF="n.type" Absorber_thick=200 Dop_absorber=2e16 Dop_BSF=1e20 BSF_thick=0.5 tau_emitter=5e-3 tau_absorber=5e-3 tau_BSF=5e-3 Va_max=-0.8 Vstep_dark=-0.01 Vstep_light=0.01'
```
Result: Jsc 30.89 mA/cm², Voc 0.721 V, FF 84.6 %, η 18.85 %. Fixed geometry: 1 µm × 1 µm cell, 0.5 µm p+ emitter at 5e19 cm⁻³.
