# Emotion-Expression-fMRI
Analysis scripts accompanying:

> Mano, Y., Nakaya, K., Komeda, H., Toyama, A., Fukuda, H., Miyamoto, Y., Kitayama, S., & Suzuki, S. (2026).

**Neural mechanisms underlying decisions to express or suppress emotions.**

*Social Cognitive and Affective Neuroscience.*

https://doi.org/10.1093/scan/nsag068

The corresponding MRI dataset is publicly available from **OpenNeuro**.

---

# Overview

This repository contains the scripts used to reproduce the preprocessing, statistical analyses, ROI analyses, and figures reported in the manuscript.

The repository is organized according to the analysis pipeline, from preprocessing through manuscript figure generation.

---

# Requirements

The analyses were performed using:

- MATLAB R2024b
- SPM25
- Docker Desktop
- dcm2bids
- fMRIPrep 23.2.1

---

# Repository Structure

## 01_preprocessing

Scripts for:

- DICOM → BIDS conversion
- fMRIPrep preprocessing
- Spatial smoothing

---

## 02_firstLevel

Scripts for:

- First-level GLM specification
- Model estimation
- Contrast generation

---

## 03_secondLevel

Scripts for:

- Group-level analyses
- One-sample t-tests
- Regression analyses

---

## 04_ROI

Scripts for:

- ROI analyses
- ROI extraction
- ROI visualization

---

## 05_figures

Scripts used to generate the figures reported in the manuscript.

---

# Workflow

```
OpenNeuro Dataset
        │
        ▼
DICOM → BIDS
        │
        ▼
fMRIPrep
        │
        ▼
Spatial smoothing
        │
        ▼
First-level GLM
        │
        ▼
Second-level GLM
        │
        ▼
ROI analyses
        │
        ▼
Figures
```

## Example Run fMRIPrep for one participant.
matlab
projectRoot = 'D:\MRI_data_new';

f01_runFMRIPrep("001", projectRoot);

---

# Usage Examples

The preprocessing functions process one participant at a time.

## DICOM-to-BIDS conversion

```matlab
projectRoot = "D:\MRI_data_new";

f00_convertDicomToBIDS( ...
    "em0001", ...
    "001", ...
    projectRoot, ...
    "latest", ...
    false, ...
    false);
```

---

# Notes

- Users should modify directory paths according to their local computing environment.
- The scripts were developed on Windows.
- Some preprocessing steps require Docker Desktop.
- Software versions may affect reproducibility.
- Minor modifications may be required before executing the scripts in different computing environments.

---

# OpenNeuro Dataset

The MRI dataset accompanying this repository is publicly available from OpenNeuro.

Dataset:
https://openneuro.org/datasets/ds008583

The DOI will be added after OpenNeuro publication.

---

# Citation

If you use these scripts, please cite:

Mano, Y., Nakaya, K., Komeda, H., Toyama, A., Fukuda, H., Miyamoto, Y., Kitayama, S., & Suzuki, S. (2026).

**Neural mechanisms underlying decisions to express or suppress emotions.**

*Social Cognitive and Affective Neuroscience.*

https://doi.org/10.1093/scan/nsag068

Please also cite the corresponding OpenNeuro dataset.
