# Analysis Pipeline

```text
Raw DICOM
   ↓
BIDS conversion
   ↓
fMRIPrep 23.2.1
   ↓
SPM25 smoothing (6-mm FWHM)
   ↓
First-level GLM
   ├─ Sentence/pmod model
   └─ Decision Yes/No model
   ↓
First-level contrasts
   ↓
Second-level one-sample t-tests (N = 40)
   ↓
Whole-brain cluster inference
   ├─ voxel p < .001 uncorrected
   └─ cluster FWE p < .05
   ↓
ROI extraction
   ├─ right TPJ [60 -58 35]
   └─ right dlPFC [48 21 44]
   ↓
Questionnaire correlations
   ├─ TAS-20
   └─ independent − interdependent self-construal
   ↓
Figure generation
```

## Behavioral branch

```text
Task logs + post-scan ratings
   ↓
Trial-level merged table
   ↓
Miss-trial exclusion
   ↓
Within-participant valence/arousal standardization
   ↓
GLMMs
   ├─ main linear model
   ├─ individual-difference model
   ├─ quadratic model
   ├─ context model
   └─ engagement model
```
