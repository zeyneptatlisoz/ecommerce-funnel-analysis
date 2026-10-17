CREATE OR REPLACE TABLE
`project-c1d1da1a-681f-456f-aa9.ecommerce_funnel.funnel_steps` AS
SELECT
  unique_session_id,
  session_start_datetime,
  session_date,
  landing_page,
  source,
  medium,
  campaign,
  device_category,
  device_language,
  operating_system,
  1 AS step_order,
  'Session Start' AS funnel_step
FROM `project-c1d1da1a-681f-456f-aa9.ecommerce_funnel.funnel_sessions`
UNION ALL

SELECT
  unique_session_id,
  session_start_datetime,
  session_date,
  landing_page,
  source,
  medium,
  campaign,
  device_category,
  device_language,
  operating_system,
  2 AS step_order,
  'View Item' AS funnel_step
FROM `project-c1d1da1a-681f-456f-aa9.ecommerce_funnel.funnel_sessions`
WHERE view_item_datetime IS NOT NULL
UNION ALL

SELECT
  unique_session_id,
  session_start_datetime,
  session_date,
  landing_page,
  source,
  medium,
  campaign,
  device_category,
  device_language,
  operating_system,
  3 AS step_order,
  'Add to Cart' AS funnel_step
FROM `project-c1d1da1a-681f-456f-aa9.ecommerce_funnel.funnel_sessions`
WHERE add_to_cart_datetime IS NOT NULL
UNION ALL

SELECT
  unique_session_id,
  session_start_datetime,
  session_date,
  landing_page,
  source,
  medium,
  campaign,
  device_category,
  device_language,
  operating_system,
  4 AS step_order,
  'Begin Checkout' AS funnel_step
FROM `project-c1d1da1a-681f-456f-aa9.ecommerce_funnel.funnel_sessions`
WHERE begin_checkout_datetime IS NOT NULL
UNION ALL

SELECT
  unique_session_id,
  session_start_datetime,
  session_date,
  landing_page,
  source,
  medium,
  campaign,
  device_category,
  device_language,
  operating_system,
  5 AS step_order,
  'Add Shipping Info' AS funnel_step
FROM `project-c1d1da1a-681f-456f-aa9.ecommerce_funnel.funnel_sessions`
WHERE add_shipping_info_datetime IS NOT NULL

UNION ALL

SELECT
  unique_session_id,
  session_start_datetime,
  session_date,
  landing_page,
  source,
  medium,
  campaign,
  device_category,
  device_language,
  operating_system,
  6 AS step_order,
  'Add Payment Info' AS funnel_step
FROM `project-c1d1da1a-681f-456f-aa9.ecommerce_funnel.funnel_sessions`
WHERE add_payment_info_datetime IS NOT NULL

UNION ALL

SELECT
  unique_session_id,
  session_start_datetime,
  session_date,
  landing_page,
  source,
  medium,
  campaign,
  device_category,
  device_language,
  operating_system,
  7 AS step_order,
  'Purchase' AS funnel_step
FROM `project-c1d1da1a-681f-456f-aa9.ecommerce_funnel.funnel_sessions`
WHERE purchase_datetime IS NOT NULL;
