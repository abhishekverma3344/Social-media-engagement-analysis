# Social Media Engagement & User Behavior Analytics

![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Excel](https://img.shields.io/badge/Excel-217346?style=for-the-badge&logo=microsoft-excel&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Database_Analysis-00758F?style=for-the-badge)
![PowerPoint](https://img.shields.io/badge/PowerPoint-B7472A?style=for-the-badge&logo=microsoft-powerpoint&logoColor=white)

An end-to-end data analytics project using **MySQL** and **Excel** to analyze user interaction dynamics on an Instagram-like social network. This project evaluates user activity patterns, isolates inactive cohorts, identifies peak engagement windows, and derives data-driven recommendations for user retention and content optimization.

---

## 📌 Project Overview

Understanding user engagement is critical for platform growth and content strategy. By writing complex SQL queries (CTEs, aggregate functions, multi-table JOINs, subqueries) across 6 relational tables, this analysis delivers actionable business insights covering:

- **Database Engineering**: Design and implementation of a full relational schema (Users, Photos, Likes, Comments, Follows, Tags).
- **Core Engagement Metrics**: Calculating Engagement Rates, Loyalty Scores, and Power-User distributions.
- **Content Performance**: Identifying top-performing hashtags and peak posting times.
- **User Segmentation**: Isolating active creators, brand advocates, and high-risk inactive segments.

---

## 📊 Relational Database Schema (ER Diagram)

<div align="center">
  <img src="https://github.com/user-attachments/assets/a0c9657e-5840-48d4-ad6b-e93ef31a6d56" alt="Database Schema ERD" width="700"/>
  <p><i>Relational Schema modeling Instagram-like user interactions, content tags, and engagement loops.</i></p>
</div>

---

## 🗂️ Key SQL Queries & Analytics Performed

### 1. User Activity & Engagement Profiling
- **Top Active Users**: Identified power users based on post frequency, comments, and likes given.
- **Inactive User Identification**: Isolated churned accounts with zero likes, posts, or comments for re-activation targeting.
- **Loyalty Score Algorithm**: Calculated composite loyalty scores leveraging post count, follower metrics, and comment interaction density.

### 2. Content & Hashtag Optimization
- **Hashtag Performance**: Analyzed tag co-occurrence to find high-reach content categories (#smile, #fun, #beach, #delicious).
- **Tag-Based Engagement Comparison**: Evaluated average likes/comments generated per hashtag category.

### 3. Posting Time & Behavioral Trends
- **Peak Activity Windows**: Aggregated post timestamps to discover optimal posting hours that maximize initial reach.
- **Audience Segmentation**: Categorized users into Active, Semi-Active, and Inactive tiers for targeted marketing campaigns.

---

## 📈 Visualizations & Dashboards (Excel)

> *The raw SQL query results were exported and structured into interactive Excel visuals and charts.*

<div align="center">

| Top Engaged Users & Activity | Posting Hour Trends & Peak Windows |
| :---: | :---: |
| ![Top Users Placeholder](https://via.placeholder.com/400x250.png?text=Top+10+Engaged+Users+Chart) | ![Posting Hour Placeholder](https://via.placeholder.com/400x250.png?text=Posting+Hour+Trends+Chart) |

| User Base Segmentation | Top Hashtags by Reach |
| :---: | :---: |
| ![User Segmentation Placeholder](https://via.placeholder.com/400x250.png?text=Inactive+vs+Active+Users) | ![Hashtags Placeholder](https://via.placeholder.com/400x250.png?text=Best+Performing+Hashtags) |

</div>

*(Note: Replace the placeholder image URLs above with your actual uploaded screenshot links on GitHub!)*

---

## 🧠 Key Business Insights

* ⏰ **Optimal Posting Window**: Content published during **5:00 PM – 6:00 PM** receives up to 35% higher initial engagement.
* ⚡ **Pareto Distribution in Engagement**: A small core group (~10% of users) accounts for the vast majority of total platform interactions.
* 🚨 **Re-Engagement Opportunity**: Over **20% of accounts are inactive**, representing a primary target for automated push notifications and email retention campaigns.
* 🏷️ **Hashtag ROI**: Posts utilizing lifestyle and visual tags (**#smile**, **#fun**, **#beach**) generate significantly higher engagement rates than generic tags.

---

## 💡 Strategic Recommendations

1. **Creator Recognition Program**: Implement verified badges or creator perks for top-tier users to boost retention.
2. **Automated Notification Triggers**: Schedule push alerts during peak interaction hours (**5–6 PM**) to maximize user click-through rates.
3. **Hashtag Recommendation Engine**: Integrate dynamic hashtag suggestions during content upload to help creators improve organic reach.
4. **Re-Activation Workflows**: Target inactive cohorts (>20% of base) with personalized digest emails highlighting trending posts.

---

## 📁 Repository Structure

```text
├── SQL_Scripts/
│   ├── 01_schema_setup.sql      # DDL table creation scripts
│   └── 02_engagement_queries.sql # CTEs, JOINs, and analytics queries
├── Dashboards/
│   └── Social_Media_Analysis.xlsx # Interactive charts & Pivot Tables
├── Presentation/
│   └── Social_Media_Insights.pptx # Executive summary deck
└── README.md                    # Project documentation
