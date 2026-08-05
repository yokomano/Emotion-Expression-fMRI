# ROI Analysis

This directory contains the ROI analyses associated with Figure 4.

## ROI definitions

Two 6-mm-radius spherical ROIs were defined from peaks in the whole-brain
Emotion No > Yes contrast:

- Right TPJ: MNI [60, -58, 35]
- Right dlPFC: MNI [48, 21, 44]

## Scripts

- `roi_extract.m`
  - Creates the spherical masks
  - Extracts participant-level mean contrast values
  - Saves `roi_values.csv`
- `roi_statistics.m`
  - Joins ROI values with questionnaire measures
  - Runs four Pearson correlations
  - Applies Bonferroni correction across 2 ROIs × 2 questionnaire measures
  - Saves tables and scatterplots

## Questionnaire measures

- `TAS20_total_z`
- `SC_Collectivism_z`

The accepted proof describes the self-construal measure as the difference
between independent and interdependent subscale scores.

## Reported manuscript result

The accepted proof reports a significant correlation between right TPJ
activity and TAS-20 scores: r = .404, raw p = .010, Bonferroni-adjusted
p = .040.
