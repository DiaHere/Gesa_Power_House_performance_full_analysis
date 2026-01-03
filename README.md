

# Gesa Power House Performance Full Analysis

## Purpose

This project was developed as part of the **Gesa Power House Theatre Internship** to analyze theatre performance in the post-COVID period. The goal is to provide **actionable insights** for operations, marketing, finance, and programming teams to support data-driven decision-making and optimize overall theatre performance.

The analysis focuses on:

- Attendance trends and seasonality  
- Event performance and revenue drivers  
- Financial health and donor behavior  
- Marketing effectiveness and audience segmentation  
- Customer sentiment (NLP)  
- Predictive modeling for attendance and revenue  

> **Data Privacy Note**  
> All data used in this project has been **masked and altered** to protect sensitive information. Statistical patterns and relationships have been preserved to maintain analytical validity.

---

## How to Use This Project

### 1. Project Setup

#### Clone the Repository
```bash
git clone <repository-url>
````

#### Configure Database Credentials

Create a `.env.cred` file inside the `scripts/` directory:

```bash
_HOSTDB=<your-database-host>
DB_USER=<your-database-username>
DB_PASSWORD=<your-database-password>
DB_NAME=<your-database-name>
```

#### Install Dependencies

```bash
pip install -r requirements.txt
```

#### Required Tools

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

Sources include:

* Attendance records
* Event details
* Post-event surveys

#### Transform

Preprocessing scripts located in:

```
scripts/load_data_to_sql/preprocess_raw_data/
```

Tasks include:

* Handling missing values
* Standardizing date formats
* Schema alignment for SQL compatibility

#### Load

Cleaned data is loaded into a MySQL database using:

```
run_load.py
```

---

### Phase 2: Data Analysis

#### SQL Analysis

SQL queries compute:

* Monthly attendance trends
* Event performance metrics
* Revenue attribution
* First-time vs. returning visitor ratios

#### Python Advanced Analysis

Python notebooks located in:

```
analysis/Python_advanced/
```

**Notebooks:**

* `01_performance_and_financials.ipynb`

  * Attendance trends
  * Seasonality
  * Retention metrics

* `02_marketing_sentiment_nlp.ipynb`

  * Marketing channel effectiveness
  * Demographic segmentation
  * Sentiment analysis using NLP

* `03_predictive_modeling.ipynb`

  * Attendance forecasting
  * Revenue and donation modeling

---

### Phase 3: Predictive Modeling

* Time-series forecasting for seasonal attendance
* Machine learning models to identify key attendance and donation drivers
* Feature importance analysis for strategic planning

---

### Phase 4: Tableau Dashboards

Insights are visualized using **Tableau dashboards**, including:

* Attendance growth analysis
* Event performance strategy
* Financial health metrics
* Marketing segmentation
* Sentiment analysis
* Predictive modeling outputs

> Interactive dashboards are published on **Tableau Public / Tableau Online**
> *(Link included in the final README or project page)*

---

## Objectives and Analysis Framework

### 1. Operational Efficiency & Audience Growth

* **Seasonality:** Attendance peaks in summer months; lowest in January–February
* **Retention:** Returning visitors account for **84%** of total attendance
* **Correlation:** First-time visitors positively correlate with total attendance, especially for family-friendly events

### 2. Event Performance Strategy

* **Top Genres:** Comedy shows and musicals consistently attract the highest attendance
* **Key Variables:** Ticket price and event duration significantly impact attendance
* **Revenue Leaders:** Workshops and musicals generate the highest average ticket revenue

### 3. Financial Health Analysis

* **Peak Revenue:** December generates the highest ticket revenue and donor engagement
* **Revenue Attribution:** Fundraisers and holiday-themed events drive seasonal revenue spikes
* **Trend Mapping:** Net revenue strongly correlates with attendance levels

### 4. Marketing & Demographic Segmentation

* **Effective Channels:** Social media and email campaigns yield the highest first-time visitor conversions
* **Core Audience:** Patrons aged **56+** form the largest and most active segment
* **Preferences:**

  * Older audiences favor musicals and workshops
  * Younger audiences show more diffuse event interest

### 5. Customer Sentiment Analysis (NLP)

* **Positive Sentiment:** Highest for comedy shows and musicals
* **Negative Feedback:** Often related to logistical issues
* **Sentiment Score:**

  * Average sentiment score: **0.46**
  * Positive feedback rate: **25%**
* **Correlation:** Higher sentiment scores align with increased attendance

### 6. Predictive Modeling & Forecasting

* **Attendance Forecast:**

  * Predicted next-season attendance: **7,609**

* **Donation Forecast:**

  * Estimated donation revenue: **$179,374**

* **Top Predictors:**

  * Event count
  * Weekend scheduling
  * First-time visitor ratios

---

## Key Findings

* Attendance exhibits strong seasonality, peaking in summer
* Returning visitors represent the majority of attendance (84%)
* Comedy shows and musicals are consistently top performers
* December is the strongest month for revenue and donations
* Social media and email are the most effective acquisition channels
* Positive sentiment strongly correlates with higher attendance
* Event volume and scheduling are critical predictors of success

---

## Tools Used

* **Python** – Data scraping, preprocessing, analysis, and modeling
* **MySQL** – Structured querying and aggregation
* **Tableau** – Dashboard visualization
* **Pandas & NumPy** – Data manipulation and statistics
* **Scikit-learn** – Machine learning and predictive modeling
* **NLP Libraries** – Sentiment analysis and theme extraction

---

## Notes

All datasets in this repository have been anonymized and altered to protect sensitive information. Analytical trends, correlations, and statistical significance have been preserved to ensure the integrity of the findings.

```

---

If you want, I can also:
- Convert this to **pure `README.md` (GitHub-optimized)**  
- Add **Tableau Public links** cleanly  
- Add a **project directory tree** section  
- Tighten this for **portfolio / recruiter readability**
```
