# First-level Analysis

This directory contains the representative first-level SPM analysis scripts
associated with Mano et al. (2026).

## Scripts

### `firstlevel_main.m`

Sentence-level parametric model corresponding to the principal analyses
shown in Figure 3.

The model includes:

- Emotion sentence presentation
- Control sentence presentation
- Valence parametric modulation of Emotion sentence presentation
- Arousal parametric modulation of Emotion sentence presentation
- Button-response events
- Missed trials
- Six rigid-body motion parameters

### `make_contrasts_main.m`

Creates the following first-level contrasts:

- `Emo_all_gt_Ctrl`
- `Ctrl_gt_Emo_all`
- `Valence_z_pos`
- `Valence_z_neg`
- `Arousal_z_pos`
- `Arousal_z_neg`

The manuscript figure mapping is:

- Figure 3a: `Emo_all_gt_Ctrl`
- Figure 3b: `Arousal_z_pos`
- Figure 3c: `Valence_z_neg`

### `firstlevel_decision.m`

Decision-phase model corresponding to the principal No-versus-Yes analysis
shown in Figure 4.

The public script is configured as a representative example for:

```text
sub-001 / em0001
```

It loads the archived multi-condition files used for the integrated decision
model.

### `make_contrasts_decision.m`

Creates the following decision-phase contrasts:

- `Decision_emo_N_gt_Y`
- `Decision_emo_Y_gt_N`
- `Decision_ctrl_N_gt_Y`
- `Decision_ctrl_Y_gt_N`

The principal Figure 4 contrast is:

```text
Decision_emo_N_gt_Y
```

## Usage

Edit the paths in the `USER SETTINGS` section at the beginning of each
MATLAB file.

Run the scripts in this order:

```matlab
firstlevel_main
make_contrasts_main

firstlevel_decision
make_contrasts_decision
```

## Example subject

The scripts use `sub-001` and `em0001` as a representative example.
The same models can be applied to the remaining included participants by
changing the subject identifiers or by using a separate batch wrapper.

## Software

- MATLAB
- SPM25
- fMRIPrep-preprocessed BOLD images
- 6-mm FWHM smoothed normalized images

## Notes

The contrast scripts locate regressors by name in `SPM.xX.name` instead of
assuming fixed design-matrix column positions. This is important because
parametric modulators add columns to the design matrix.

Before creating a permanent release, verify that regenerated first- and
second-level statistical maps match the archived manuscript results.
