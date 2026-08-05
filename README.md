# Emotion-Expression-fMRI

Analysis scripts accompanying:

> Mano, Y., Nakaya, K., Komeda, H., Toyama, A., Fukuda, H., Miyamoto, Y.,
> Kitayama, S., & Suzuki, S. (2026).  
> **Neural mechanisms underlying decisions to express or suppress emotions.**  
> *Social Cognitive and Affective Neuroscience.*  
> https://doi.org/10.1093/scan/nsag068

## Overview

This repository contains public-facing analysis scripts for the behavioral and
fMRI analyses reported in the article.

Participants decided whether they would express emotions elicited by written
scenarios while undergoing fMRI. The analyses examined:

- Emotion versus Control sentence processing
- Parametric effects of perceived valence and arousal
- Decision-related activity for Emotion No > Yes responses
- ROI associations with alexithymia and self-construal
- Behavioral generalized linear mixed-effects models

## Repository structure

```text
01_preprocessing/   DICOM/BIDS/fMRIPrep/SPM smoothing documentation
02_firstlevel/      Participant-level SPM models and contrasts
03_secondlevel/     Group-level one-sample t-tests
04_roi/             Right TPJ and right dlPFC ROI analyses
05_behavior/        Trial-level data preparation and GLMM specifications
06_figures/         Public-facing Figure 3 and Figure 4 scripts
docs/               Pipeline, manuscript mapping, and reproducibility notes
```

## Principal manuscript mapping

| Manuscript result | Public script |
|---|---|
| Figure 3a: Emotion > Control | `02_firstlevel/firstlevel_main.m` → `03_secondlevel/secondlevel_main.m` → `06_figures/figure3.m` |
| Figure 3b: Arousal positive | same pipeline |
| Figure 3c: Valence negative | same pipeline |
| Figure 4: Emotion No > Yes | `02_firstlevel/firstlevel_decision.m` → `03_secondlevel/secondlevel_main.m` |
| Figure 4 ROI correlations | `04_roi/roi_extract.m` → `04_roi/roi_statistics.m` → `06_figures/figure4.m` |
| Behavioral GLMMs | `05_behavior/prepare_behavior_data.py` → `05_behavior/glmm_models.R` |

## Software

- MATLAB R2024a
- SPM25
- fMRIPrep 23.2.1
- Nipype 1.8.6
- Python 3
- R with `lme4`

See `requirements.md`.

## Reproduction order

1. Prepare BIDS data and run fMRIPrep.
2. Apply 6-mm FWHM smoothing.
3. Run first-level models and first-level contrasts.
4. Run group-level analyses.
5. Extract ROI values and run ROI correlations.
6. Prepare behavioral data and fit GLMMs.
7. Generate figure panels.

See `docs/analysis_pipeline.md`.

## Data availability

The accepted proof states that data supporting the findings are available
from the corresponding author upon reasonable request. Update this section
when the OpenNeuro accession and permanent dataset DOI are finalized.

## Important release status

This package is a **public-release candidate** assembled from the manuscript
and the supplied analysis code.

Before creating a permanent GitHub release, verify:

- The public first-level designs against archived final `SPM.mat` files
- N = 40 for each principal group analysis
- The exact miss-trial implementation
- The four ROI correlation outputs
- Statistical maps against the final manuscript figures

See `docs/reproducibility_checklist.md`.

## License

Code is released under the MIT License. Data are not covered by the code
license and may have separate access conditions.

## Citation

See `CITATION.cff`.
