# Monthly-Attendance-and-Event-Performance-Analysis
Gesa Power House Theatre Internship

Create a `.env.cred` file in the `scripts` directory with your local database credentials.

### 1. Operational Efficiency & Audience Growth
* **Assess Seasonality:** Identify seasonal peaks, slumps, and optimal scheduling windows by analyzing monthly attendance trends (excluding incomplete 2025 data).
* **Measure Retention:** Evaluate audience loyalty and long-term engagement by tracking the ratio of first-time vs. returning visitors over a two-year period.
* **Investigate Correlations:** Determine if there is a statistical relationship between first-time visitors and total general attendance.
  - Use python to see which event types yield the most attendance

### 2. Event Performance Strategy
* **Benchmark Success:** Compare high-performing vs. low-performing events to isolate the specific characteristics (genre, timing, cast) that drive ticket sales.
* **Analyze Variables:** Determine the impact of event duration and average ticket pricing on total attendance numbers.
* **Ticket Profits:** identify the average profit generated from tickets per event. 
  
### 3. Financial Health Analysis
* **Identify Profit Drivers:** Identify which months generate higher ticket revenue versus which months generate higher donor engagement, and determine which events fall within those months.
  -  I plan to further analyze the specific events in months where ticket revenue exceeded donations using Python, allowing a deeper investigation into which productions or programming patterns contribute most to earned-income peaks
* **Attribute Revenue:** Isolate the specific months that generate the highest net financial gain and list the events contributing to that gain.
  - I will use Python NLP to categorize event types and determine which kinds of programming contribute most to this seasonal revenue peak.
* **Map Trends:** Chart monthly financial performance to pinpoint the theatre's strongest and weakest fiscal periods.
  - Visualize later
* **Test Hypothesis:** Determine the extent to which monthly attendance influences net revenue by estimating the effect of attendance on net revenue while controlling for seasonal patterns.

### 4. Marketing & Demographic Segmentation
* **Evaluate Channels:** Assess which marketing channels yield the highest conversion rate for *new* visitors.
* **Profile Demographics:** Segment the audience by age and income groups to understand the current attendee composition.
* **Map Preferences:** Correlate demographic segments with specific event types to help tailor future programming and marketing campaigns.

### 5. Customer Sentiment Analysis (NLP)
* **Extract Themes:** Implement **Natural Language Processing (NLP)** techniques to identify recurring positive and negative themes within unstructured survey feedback.
* **Score Sentiment:** Calculate sentiment scores per event and month to quantitatively measure audience satisfaction.
* **Correlate Data:** Compare qualitative sentiment scores against quantitative attendance metrics to determine if satisfaction levels directly impact footfall.

### 6. Predictive Modeling & Forecasting
* **Forecast Attendance:** Develop time-series forecasts to project monthly attendance figures for the upcoming season.
* **Identify Features:** Determine which features (e.g., day of week, duration, demographics) are the strongest predictors of high attendance.
* **Model Revenue:** Construct **predictive models** to estimate future donation levels based on attendance variables and first-time visitor ratios.
