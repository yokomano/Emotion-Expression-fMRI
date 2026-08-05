# Manuscript–Code Mapping

| Manuscript section/result | Model or contrast | Public code |
|---|---|---|
| MRI preprocessing | fMRIPrep + 6-mm smoothing | `01_preprocessing/` |
| Figure 3a | Emotion > Control during sentence presentation | `02_firstlevel/firstlevel_main.m`, `02_firstlevel/make_contrasts_main.m`, `03_secondlevel/secondlevel_main.m`, `06_figures/figure3.m` |
| Figure 3b | Arousal positive pmod in Emotion condition | same as above |
| Figure 3c | Valence negative pmod in Emotion condition | same as above |
| Figure 4a/c | Emotion No > Yes decision contrast | `02_firstlevel/firstlevel_decision.m`, `02_firstlevel/make_contrasts_decision.m`, `03_secondlevel/secondlevel_main.m`, `06_figures/figure4.m` |
| Figure 4b/d | ROI × TAS-20 / ΔSC correlations | `04_roi/roi_extract.m`, `04_roi/roi_statistics.m`, `06_figures/figure4.m` |
| Behavioral main GLMM | Yes ~ valence + arousal | `05_behavior/glmm_models.R` |
| Behavioral moderator GLMM | TAS-20 and self-construal interactions | `05_behavior/glmm_models.R` |
| Behavioral quadratic analysis | valence² and arousal² | `05_behavior/glmm_models.R` |
