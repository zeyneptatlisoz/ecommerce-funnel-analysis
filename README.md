
# E-Commerce Funnel Analysis

## Project Overview

GoIT Data Analytics eğitimi kapsamında geliştirdiğim bireysel veri analizi projesidir.

Bu projede Google Analytics 4 (GA4) genel e-ticaret veri setini kullanarak kullanıcıların web sitesine girişinden satın almaya kadar olan yolculuğunu analiz ettim. Amaç, pazarlama yöneticilerinin dönüşüm oranlarını ve kullanıcı kayıplarını inceleyebileceği interaktif bir dashboard oluşturmaktır.

## Tools & Technologies

- Google BigQuery
- SQL
- Looker Studio

## Funnel Stages

1. Session Start
2. View Item
3. Add to Cart
4. Begin Checkout
5. Add Shipping Info
6. Add Payment Info
7. Purchase

## Key Findings

- Session Start → View Item dönüşümü: %19,25
- View Item → Add to Cart dönüşümü: %18,24
- Add Payment Info → Purchase dönüşümü: %72,49
- En belirgin kullanıcı kayıpları funnel'ın erken aşamalarında gerçekleşmektedir.

## Project Files

### SQL Queries
- [Session-Level Funnel Analysis](sql/funnel_sessions.sql)
- [Funnel Steps for Visualization](sql/funnel_steps.sql)

## Live Dashboard
[View Interactive Dashboard](https://datastudio.google.com/reporting/698aa941-94c4-4164-ab13-db0927c02b07)

### Project Presentation
[View Project Presentation](Zeynep_Tatlisoz_Ecommerce_Funnel_Analysis.pdf.pdf)
