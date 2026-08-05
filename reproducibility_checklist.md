# Reproducibility Checklist

## Principal analyses

- [ ] Figure 3a includes exactly N = 40
- [ ] Figure 3b includes exactly N = 40
- [ ] Figure 3c includes exactly N = 40
- [ ] Figure 4 includes exactly N = 40
- [ ] Each group analysis has an archived `included_subjects.txt`
- [ ] Public contrast names match archived `SPM.xCon.name`

## First-level specification

- [ ] Emotion and Control sentence durations verified as 4 s
- [ ] Decision durations verified as reaction time
- [ ] Button-response regressor verified
- [ ] Miss-trial regressor verified
- [ ] Miss duration verified as 4 s
- [ ] Valence/arousal standardized within participant
- [ ] Parametric-modulator orthogonalization disabled
- [ ] Six motion regressors included

## ROI

- [ ] Right TPJ coordinate verified: [60 -58 35]
- [ ] Right dlPFC coordinate verified: [48 21 44]
- [ ] Sphere radius verified: 6 mm
- [ ] Four ROI correlations reproduced
- [ ] Bonferroni correction across four tests reproduced
- [ ] Right TPJ × TAS-20 result reproduced: r = .404, p = .010, adjusted p = .040

## Figures and tables

- [ ] Figure 3 maps match archived publication maps
- [ ] Figure 4 maps match archived publication maps
- [ ] Figure 4 scatterplots match archived values
- [ ] Cluster sizes, peak T values, coordinates, and FWE p values match Table 2
- [ ] Final typography and layout checked against publication proofs

## Release metadata

- [ ] OpenNeuro accession added
- [ ] Permanent dataset DOI added
- [ ] GitHub release created
- [ ] Release archived in Zenodo, if applicable
- [ ] `CITATION.cff` updated with repository DOI
