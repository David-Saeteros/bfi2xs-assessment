# BFI-2-XS Personality Assessment Tool

![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)
![R Version](https://img.shields.io/badge/R-%3E%3D%204.0.0-brightgreen)

A reliable and easy-to-use R package for calculating and analyzing personality scores using the Big Five Inventory-2-Extra Short Form (BFI-2-XS).

## 📋 Table of Contents

- [Overview]([#overview](https://github.com/David-Saeteros/bfi2xs-assessment#-overview))
- [The Big Five Personality Traits](#the-big-five-personality-traits)
- [Installation](#installation)
- [Usage](#usage)
- [Input Data Format](#input-data-format)
- [Output](#output)
- [Examples](#examples)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [License](#license)

## 🔍 Overview

The BFI-2-XS is a brief 15-item measure for assessing the Big Five personality domains. This tool allows researchers and practitioners to:

- Calculate personality scores from BFI-2-XS questionnaire data
- Analyze correlations between personality dimensions
- Visualize personality traits
- Export results for further analysis

This implementation supports both English and Spanish versions of the BFI-2-XS assessment.

## 🧠 The Big Five Personality Traits

The BFI-2-XS measures five broad dimensions of personality:

1. **Extraversion**: Sociability, assertiveness, and positive emotionality
2. **Agreeableness**: Prosocial tendencies, compassion, and respectfulness
3. **Conscientiousness**: Organization, productivity, and responsibility
4. **Negative Emotionality** (Neuroticism): Anxiety, depression, and emotional volatility
5. **Open-Mindedness** (Openness): Intellectual curiosity, aesthetic sensitivity, and creative imagination

Each dimension is measured using 3 items in the BFI-2-XS, making it an efficient personality assessment tool.

## 💻 Installation

### Prerequisites

- R (≥ 4.0.0)
- Required packages: dplyr, car, psych, stargazer, readr

### Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/bfi2xs-assessment.git
   cd bfi2xs-assessment
   ```

2. Install required R packages:
   ```r
   if (!requireNamespace("pacman", quietly = TRUE)) {
     install.packages("pacman")
   }
   pacman::p_load(dplyr, car, psych, stargazer, readr)
   ```

## 🚀 Usage

Basic usage of the BFI-2-XS assessment tool:

```r
# Source the main script
source("bfi2xs_assessment.R")

# Run the analysis with your data files
results <- run_bfi2xs_analysis(
  numeric_file = "your_data.csv", 
  categorical_file = NULL,  # Optional
  spanish_version = TRUE,   # Set to FALSE for English version
  export_csv = TRUE,
  analyze_cors = TRUE
)

# View summary statistics of personality dimensions
summary(results[, c("Agreeableness", "Neuroticism", "Conscientiousness", "Openness", "Extraversion")])

# Generate basic visualizations
boxplot(results[, c("Agreeableness", "Neuroticism", "Conscientiousness", "Openness", "Extraversion")],
        main = "Distribution of Big Five Personality Traits",
        col = c("#FF9999", "#66CCFF", "#99FF99", "#FFCC99", "#CC99FF"))
```

## 📊 Input Data Format

The tool accepts CSV files with the following format:

### Required Columns

Your CSV should contain these columns for the BFI-2-XS items based on the version you're using (Spanish or English). 

**Optional**: If your data comes from Qualtrics or another survey platform that includes a `Progress` column, the tool can use it to filter out incomplete responses. If no `Progress` column is present, all responses will be used.

### For the Spanish version (SP-BFI-2-XS):

Your CSV should contain these columns for the BFI-2-XS items:
- `compasivo` (Compasivo/a, con un gran corazón)
- `relajado` (Relajado/a, que gestiona bien el estrés)
- `respetuoso` (Respetuoso/a, que trata a los demás con respeto)
- `formal` (Formal, constante)
- `callado` (Que tiende a estar callado/a)
- `arte` (Fascinado/a por el arte, la música o la literatura)
- `dominante` (Dominante, que actúa como líder)
- `estable` (Emocionalmente estable, que no se altera con facilidad)
- `ordenado` (Que mantiene todo limpio y ordenado)
- `energizado` (Lleno/a de energía)
- `tenaz` (Tenaz, que trabaja hasta terminar la tarea)
- `melancolico` (Que tiende a sentirse deprimido/a, melancólico/a)
- `abstracto` (Con poco interés por ideas abstractas)
- `bienpensado` (Que piensa bien de la gente)
- `original` (Original, que aporta ideas nuevas)

### For the English version (BFI-2-XS):

Your CSV should contain these columns for the BFI-2-XS items:
- `talkative` (Is talkative)
- `fault` (Tends to find fault with others)
- `thorough` (Does a thorough job)
- `depressed` (Is depressed, blue)
- `original` (Is original, comes up with new ideas)
- `reserved` (Is reserved)
- `helpful` (Is helpful and unselfish with others)
- `careless` (Can be somewhat careless)
- `relaxed` (Is relaxed, handles stress well)
- `curious` (Is curious about many different things)
- `energy` (Is full of energy)
- `quarrels` (Starts quarrels with others)
- `reliable` (Is a reliable worker)
- `tense` (Can be tense)
- `ingenious` (Is ingenious, a deep thinker)

The data should be in Likert scale format (typically 1-5).

## 📈 Output

The tool produces the following outputs:

1. **Calculated Scores**: A data frame with the original items and calculated scores for each personality dimension
2. **CSV Export**: Results saved as a CSV file
3. **Correlation Analysis**: Visual representation of the correlations between items
4. **HTML Report**: Optional correlation matrix in HTML format

## 🧪 Examples

### Example 1: Basic Analysis

```r
# Run analysis with default settings
results <- run_bfi2xs_analysis("BFI2XS_data.csv")

# View the first few rows of results
head(results)
```

### Example 2: Customized Analysis

```r
# Run analysis with custom settings
results <- run_bfi2xs_analysis(
  numeric_file = "BFI2XS_data.csv",
  spanish_version = FALSE,  # Use English item names
  export_csv = TRUE,
  analyze_cors = TRUE
)

# Create a custom visualization
library(ggplot2)

# Prepare data for plotting
plot_data <- data.frame(
  Dimension = rep(c("Agreeableness", "Neuroticism", "Conscientiousness", "Openness", "Extraversion"), each = nrow(results)),
  Score = c(results$Agreeableness, results$Neuroticism, results$Conscientiousness, results$Openness, results$Extraversion)
)

# Create violin plot
ggplot(plot_data, aes(x = Dimension, y = Score, fill = Dimension)) +
  geom_violin(trim = FALSE) +
  geom_boxplot(width = 0.1, fill = "white") +
  labs(title = "Distribution of Big Five Personality Traits",
       y = "Score", x = "") +
  theme_minimal() +
  scale_fill_brewer(palette = "Pastel1")
```

## 📖 Documentation

For detailed documentation, see:

- [Scoring Methodology](docs/scoring_methodology.md)

## 👥 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📚 References

- Gallardo-Pujol, D., Rouco, V., Cortijos-Bernabeu, A., Oceja, L., Soto, C. J., & John, O. P. (2022). Factor Structure, Gender Invariance, Measurement Properties, and Short Forms of the Spanish Adaptation of the Big Five Inventory-2. Psychological Test Adaptation and Development, 3(1), 44–69. https://doi.org/10.1027/2698-1866/a000020
- Soto, C. J., & John, O. P. (2017). The next Big Five Inventory (BFI-2): Developing and assessing a hierarchical model with 15 facets to enhance bandwidth, fidelity, and predictive power. Journal of Personality and Social Psychology, 113(1), 117-143.
- Soto, C. J., & John, O. P. (2017). Short and extra-short forms of the Big Five Inventory–2: The BFI-2-S and BFI-2-XS. Journal of Research in Personality, 68, 69-81.
