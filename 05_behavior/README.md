# Behavioral Analysis

This directory contains scripts and documentation for the behavioral analyses.

## Primary GLMM

The manuscript specifies:

```text
logit(P(Yes)) ~ 1 + V + A + (1 + V + A | Participant)
```

where `V` and `A` are z-standardized valence and arousal ratings.

## Individual-difference GLMM

```text
logit(P(Yes)) ~ 1 + V + A + QA + QS
                + V × QA + V × QS
                + A × QA + A × QS
                + (1 + V + A | Participant)
```

## Exploratory models

- Quadratic valence and arousal effects
- Relational versus individual context
- Engaged versus disengaged emotion scenarios

## Files

- `prepare_behavior_data.py`
  - Combines task logs and post-scan ratings
  - Restricts data to the final analysis sample
  - Removes duplicate records
  - Creates trial-level analysis data
- `glmm_models.R`
  - Public model specification template corresponding to the manuscript

The exact R package versions and archived model output should be verified
before a permanent release.
