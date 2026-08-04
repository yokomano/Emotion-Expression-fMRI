# Second-level Analysis

This directory contains the group-level SPM analysis script associated with
the principal fMRI results reported in Mano et al. (2026).

## Script

### `secondlevel_main.m`

Runs one-sample t-tests across the final sample of 40 participants.

The script locates each participant's first-level contrast image by contrast
name in `SPM.xCon`, rather than assuming fixed `con_XXXX.nii` numbers.

## Analyses

- Figure 3a: `Emo_all_gt_Ctrl`
- Figure 3b: `Arousal_z_pos`
- Figure 3c: `Valence_z_neg`
- Figure 4: `Decision_emo_N_gt_Y`

## Required first-level roots

The `USER SETTINGS` section should point to:

```text
firstlevel_main_all_subjects/
firstlevel_decision_all_subjects/
```

Each root should contain participant folders such as:

```text
sub-001/
sub-002/
...
```

The script searches recursively below each participant folder for `SPM.mat`.

## Output

The script creates:

```text
secondlevel_public/
├── Figure3a_Emo_gt_Ctrl/
├── Figure3b_Arousal_pos/
├── Figure3c_Valence_neg/
└── Figure4_No_gt_Yes/
```

Each output directory contains the group-level SPM results and an
`included_subjects.txt` file.

## Sample size

The script requires exactly:

```text
N = 40
```

It stops if the number of valid contrast images differs from 40.

## Usage

Edit:

```matlab
spmDir
model1Root
decisionRoot
secondRoot
```

Then run:

```matlab
secondlevel_main
```

## Software

- MATLAB
- SPM25

## Verification before release

Confirm that:

1. Each analysis includes exactly 40 participants.
2. Contrast names match the first-level `SPM.xCon` entries.
3. Regenerated statistical maps match the archived manuscript results.
