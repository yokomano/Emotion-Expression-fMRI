# Behavioral GLMM specifications for Mano et al. (2026)
#
# Required packages:
# install.packages(c("lme4", "lmerTest", "readr", "dplyr"))

library(lme4)
library(readr)
library(dplyr)

# USER SETTINGS
data_file <- "path/to/behavior_for_analysis.csv"

dat <- read_csv(data_file, show_col_types = FALSE) |>
  filter(condition == "emo", !is_miss)

# Main model
model_main <- glmer(
  resp_yes ~ valence_z + arousal_z +
    (1 + valence_z + arousal_z | subject_id),
  data = dat,
  family = binomial(link = "logit")
)

summary(model_main)

# Individual-difference model
# Expected participant-level columns:
# TAS20_total_z and SC_Collectivism_z
model_individual_differences <- glmer(
  resp_yes ~ valence_z + arousal_z +
    TAS20_total_z + SC_Collectivism_z +
    valence_z:TAS20_total_z +
    valence_z:SC_Collectivism_z +
    arousal_z:TAS20_total_z +
    arousal_z:SC_Collectivism_z +
    (1 + valence_z + arousal_z | subject_id),
  data = dat,
  family = binomial(link = "logit")
)

summary(model_individual_differences)

# Exploratory quadratic model
model_quadratic <- glmer(
  resp_yes ~ valence_z + arousal_z +
    I(valence_z^2) + I(arousal_z^2) +
    (1 + valence_z + arousal_z +
       I(valence_z^2) + I(arousal_z^2) | subject_id),
  data = dat,
  family = binomial(link = "logit")
)

summary(model_quadratic)
