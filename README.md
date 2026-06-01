# Master in Economics & Econometrics — Projects

A collection of projects developed during my Master's studies in Economics and Econometrics.
Each folder is a self-contained project covering a different area — from **machine learning forecasting**
and **structural macroeconometrics** to **causal inference** and **NLP-based sentiment analysis** —
and combines applied econometric theory with hands-on implementation in **R, MATLAB, Python, and Stata**.

---

## 📚 Projects

| Project | Topic | Tools |
|---|---|---|
| [Machine-Learning-Forecasting](#-machine-learning-forecasting) | Forecasting with approximate dynamic factor models | R |
| [Macroeconometrics-SVAR](#-macroeconometrics-svar) | Fiscal policy shocks via Structural VARs | MATLAB |
| [Sentiment-Analysis-ISTAT](#-sentiment-analysis-istat) | NLP classification of tweets (BERT vs. classical ML) | Python |
| [Synthetic-DiD](#-synthetic-did) | Carbon taxes & CO₂ emissions via Synthetic DiD | Stata |

---

### 📈 Machine-Learning-Forecasting
Replication and extension of the paper *"Forecasting with approximate dynamic factor models:
the role of non-pervasive shocks"*. The project investigates how non-pervasive (local) shocks
affect the forecasting performance of approximate dynamic factor models.

- **Language:** R
- **Contents:** data-cleaning and modelling scripts (`R Codes/`), datasets (`Data/`), and a written report (`PDFs/MLE.pdf`)
- **Joint work with** Nicola Cassarino, Virginia Pagliero, and Benedikt Scheid.

### 🏛️ Macroeconometrics-SVAR
Extension of Blanchard & Perotti (2002), *"An Empirical Characterization of the Dynamic Effects
of Changes in Government Spending and Taxes on Output"*. The analysis studies the dynamic causal
effects of tax and government-spending shocks on GDP, with and without cointegration.

- **Language:** MATLAB
- **Contents:** estimation code (`MATLAB codes/`) for preliminary graphs, the cointegrated and
  non-cointegrated specifications, plus the full write-up (`Bertoia_Pagliero.pdf`)
- **Joint work with** Virginia Pagliero.

### 💬 Sentiment-Analysis-ISTAT
Classification of gender-based-violence Italian tweets using transformer models (**BERT**),
benchmarked against classical machine-learning approaches (**SVM** and **Naïve Bayes**).
Includes both sentiment and emotion classification, along with data-visualization notebooks.

- **Language:** Python (Jupyter notebooks)
- **Contents:** BERT, SVM/Naïve Bayes, and VADER notebooks (`Python Codes/`), plus the
  Master's thesis and presentation slides (`Thesis and Slides/`)

### 🌍 Synthetic-DiD
Replication study and extension of *"Carbon Taxes and CO₂ Emissions: Sweden as a Case Study"*,
applying the **Synthetic Difference-in-Differences** estimator to evaluate the effect of carbon
taxation on emissions.

- **Language:** Stata
- **Contents:** replication of the paper's figures and tables (`Replication Study/`), an original
  extension (`Extension/`), and supporting reports
- Original article and replication package: <https://www.aeaweb.org/articles?id=10.1257/pol.20170144>

---

## 🗂️ Repository structure

```
Master_Economics_Econometrics/
├── Machine-Learning-Forecasting/   # R — dynamic factor model forecasting
├── Macroeconometrics-SVAR/         # MATLAB — fiscal policy SVAR
├── Sentiment-Analysis-ISTAT/       # Python — BERT vs. classical ML (master's thesis)
└── Synthetic-DiD/                  # Stata — synthetic difference-in-differences
```

Each project keeps its own `README.md` with further details.

---

## 👤 Author

**Federico Bertoia** — Master in Economics & Econometrics
Some projects were carried out in collaboration with fellow students, as noted above.
