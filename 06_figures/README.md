# Figure Generation

This directory contains public-facing figure-generation scripts.

## Files

- `figure3.m`
  - Displays thresholded maps for:
    - Emotion > Control
    - Arousal positive
    - Valence negative
- `figure4.m`
  - Displays the No > Yes statistical map at the right dlPFC and right TPJ
  - Creates questionnaire–ROI correlation panels from the joined ROI table

## Thresholding

The manuscript states that the displayed activation maps were thresholded at
p < .001 uncorrected for display. Inferential significance was assessed using
cluster-level FWE correction at p < .05.

## Important note

These public scripts recreate the statistical content but may not exactly
match the final manuscript's typography, cropping, color scale, or panel
arrangement. Verify against the archived final figure files before release.
