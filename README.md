# Theatre's Performance Full Analysis

**Author:** Gesa Power House Theatre Internship

---

## Purpose

This project was developed as part of the **Gesa Power House Theatre Internship** to analyze theatre performance in the post-COVID period. The objective is to generate **actionable, data-driven insights** for internal teams including **operations, marketing, finance, and programming**.

The analysis examines:

* Monthly and seasonal attendance trends
* Event performance and pricing behavior
* Financial health and revenue drivers
* Marketing channel effectiveness
* Audience demographics and engagement
* Customer sentiment using Natural Language Processing (NLP)
* Predictive modeling for attendance and revenue forecasting

> **Data Privacy Statement**
> All datasets used in this project have been **masked and altered** to protect sensitive organizational and patron information. While raw values have been modified, **statistical relationships, distributions, and significance have been preserved** to maintain analytical validity.

---

## How to Use This Project

### Project Setup

#### 1. Clone the Repository

```bash
git clone <repository-url>
```

#### 2. Configure Database Credentials

Create a `.env.cred` file inside the `scripts/` directory:

```bash
_HOSTDB=<your-database-host>
DB_USER=<your-database-username>
DB_PASSWORD=<your-database-password>
DB_NAME=<your-database-name>
```

#### 3. Install Required Dependencies

```bash
pip install -r requirements.txt
```

#### 4. Required Software

* **Python 3.9+**
* **MySQL**
* **Tableau** (for dashboard visualization)

---

## Project Workflow

### Phase 1: ETL Process

#### Extract

Data is scraped using Python scripts located in:

```
scripts/load_data_to_data_raw/
```

Extracted datasets include:

* Attendance records
* Event metadata
* Ticket sales data
* Post-event audience surveys

#### Transform

Raw datasets are cleaned and standardized using preprocessing scripts located in:

```
scripts/load_data_to_sql/preprocess_raw_data/
```

Transformation tasks include:

* Handling missing and inconsistent values
* Standardizing date and time formats
* Normalizing categorical variables
* Aligning schemas for SQL ingestion

#### Load

Processed data is loaded into a MySQL database using:

```
run_load.py
```

This enables structured querying and downstream analytical workflows.

---

### Phase 2: Data Analysis

#### SQL Analysis

SQL queries are used to compute:

* Monthly attendance trends
* Event-level performance metrics
* Revenue attribution across event types
* First-time versus returning visitor ratios

These queries support high-level reporting and feed into advanced analytics.

#### Python Advanced Analysis

Advanced analyses are conducted using Python notebooks located in:

```
analysis/Python_advanced/
```

**Notebook Breakdown:**

* `01_performance_and_financials.ipynb`

  * Attendance trends and seasonality
  * Retention and repeat attendance metrics
  * Event-level revenue analysis

* `02_marketing_sentiment_nlp.ipynb`

  * Marketing channel effectiveness
  * Demographic segmentation
  * Sentiment analysis using NLP techniques

* `03_predictive_modeling.ipynb`

  * Attendance forecasting
  * Revenue and donation prediction
  * Feature importance analysis

---

### Phase 3: Predictive Modeling

Predictive modeling focuses on forecasting future performance and identifying drivers of success:

* Time-series–informed feature modeling for seasonal attendance
* Machine learning models to identify drivers of attendance and donations
* Emphasis on interpretability and operational relevance

---

### Phase 4: Tableau Dashboards

All analytical insights are visualized using **Tableau dashboards**, including:

* Attendance growth and seasonality
* Event performance and pricing strategy
* Financial health and revenue breakdowns
* Marketing segmentation and conversion analysis
* Audience sentiment visualization
* Predictive modeling outputs

> Interactive dashboards are published on **Tableau Public / Tableau Online**
> Links are included in the final project documentation.

---

## Key Findings & Analytical Notes

### Attendance & Audience Growth

* Attendance and first-time visitors are **positively correlated**. Higher-attendance events consistently attract more new visitors, suggesting growth momentum is strongest during already successful programming.

* **Clear seasonality** is present:

  * **Peak months:** October–December
  * **Moderate attendance:** January, March, July
  * **Lowest attendance:** August–September

* Average attendance per event is approximately **200 attendees**, providing a stable baseline for planning and forecasting.

---

### Event Pricing & Performance

* Events with **mid-range ticket prices ($15–$45)** show the most consistent attendance.

* Both lower- and higher-priced events exhibit **unpredictable attendance**, indicating non-linear price sensitivity.

* Attendance varies significantly by event type:

  * **Highest:** Comedy shows and workshops
  * **Lowest:** Music concerts and fundraisers

* These findings suggest **programming mix has a greater impact on turnout than price alone**.

---

### Revenue & Financial Trends

* Net revenue trends are **volatile**, with notable spikes occurring at unexpected times—particularly in **late 2023 and early 2024**.

* Attendance has a **statistically significant but weak relationship** with net revenue:

  * *p-value:* 0.038
  * *R²:* 0.167

* **Donations contribute more to net revenue than ticket sales** in most months, emphasizing the importance of development and donor engagement.

---

### Marketing Channel Effectiveness

* The **theatre website and email campaigns** are the most effective discovery channels.

* **Posters and radio** are the least effective, contributing minimally to audience discovery.

* These results support prioritizing **digital-first marketing strategies**.

---

### Demographics & Engagement

* Engagement increases with age, with the **highest engagement among patrons aged 56+**.

* **Musicals and workshops** are most preferred by older audiences.

* Younger audiences display **weaker and more diffuse preferences**, indicating opportunities for targeted experimentation and outreach.

---

### Audience Sentiment (NLP Analysis)

* The average sentiment score is **mildly positive (0.46)**.

* Only **~25% of survey responses** reflect strong satisfaction, indicating room for improvement.

* Sentiment trends:

  * Increased from ~0.43 to ~0.60 during 2023
  * Declined below the long-term average in 2024
  * Stabilized through 2025

* A small number of standout events drive high satisfaction:

  * *My Own Normal* (1.00)
  * *Exposure* (0.75)
  * *Peter and the Wolf* (0.71)

* Audience satisfaction appears to be driven by **exceptional programming**, not consistent baseline performance.

---

### Predictive Modeling & Forecasting Notes

* Attendance forecasts are generated using a **validated Random Forest model**:

  * *R² ≈ 0.76*

* Revenue regression models were tested and rejected due to poor predictive performance (negative R²).

* Estimated donation revenue is calculated as:

  ```
  Forecasted Attendance × Historical Average Donation per Attendee
  ```

* Forecast scenarios reflect attendance-driven scaling only:

  * Baseline: ~59,858
  * Optimistic: ~59,858
  * Conservative: ~59,656

* Differences across scenarios are small (≈200 attendees), reflecting proportional scaling.

* Attendance forecasts are feature-driven rather than trend-based, smoothing historical volatility:

  * Typical monthly range: ~1,234–1,300
  * Minimum observed: ~891
  * Maximum observed: ~1,645

* Confidence bands represent historical attendance error (MAE), not revenue uncertainty.

## Tableau Dashboards
Interactive dashboards summarizing the key findings are available at the following link:
[Tableau Online Dashboard](https://10ay.online.tableau.com/#/site/danad-f2c6f022a1/workbooks/3347826/views?order=name%3Aasc)

---

## Tools Used

* **Python** – Data scraping, preprocessing, analysis, and modeling
* **MySQL** – Structured querying and relational analysis
* **Tableau** – Dashboard creation and visualization
* **Pandas & NumPy** – Data manipulation and statistical computation
* **Scikit-learn** – Machine learning and predictive modeling
* **NLP Libraries** – Sentiment analysis and theme extraction

---

## Notes

All datasets in this repository have been anonymized and altered to protect sensitive information. Analytical trends, correlations, and statistical significance have been preserved to ensure the integrity and reliability of the findings.
