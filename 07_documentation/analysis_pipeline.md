# Analysis Pipeline

```text
Raw MRI data
    ↓
BIDS organization and OpenNeuro release
    ↓
fMRIPrep 23.2.1
    ↓
SPM25 smoothing (6-mm FWHM)
    ↓
First-level GLM
    ├── Sentence/pmod model
    └── Decision Yes/No model
    ↓
First-level contrasts
    ↓
Second-level random-effects analyses (N = 40)
    ↓
Whole-brain inference
    ├── voxel p < .001 uncorrected
    └── cluster FWE p < .05
    ↓
ROI extraction
    ├── right TPJ [60 -58 35]
    └── right dlPFC [48 21 44]
    ↓
Questionnaire correlations and manuscript figures
```
