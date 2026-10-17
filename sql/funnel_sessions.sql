
CREATE OR REPLACE TABLE `project-c1d1da1a-681f-456f-aa9.ecommerce_funnel.funnel_sessions` AS

WITH funnel_data AS (
  SELECT
    event_name,
    event_timestamp,
    CONCAT(
      user_pseudo_id,
      CAST(ep.value.int_value AS STRING)
    ) AS unique_session_id
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
    UNNEST(event_params) AS ep
  WHERE ep.key = 'ga_session_id'
    AND event_name IN (
      'session_start',
      'view_item',
      'add_to_cart',
      'begin_checkout',
      'add_shipping_info',
      'add_payment_info',
      'purchase'
    )
    AND _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
),

session_start_step AS (
  SELECT
    unique_session_id,
    MIN(
      CASE
        WHEN event_name = 'session_start'
        THEN event_timestamp
      END
    ) AS session_start_time
  FROM funnel_data
  GROUP BY unique_session_id
),

view_item_step AS (
  SELECT
    s.unique_session_id,
    s.session_start_time,
    MIN(
      CASE
        WHEN f.event_name = 'view_item'
          AND f.event_timestamp > s.session_start_time
        THEN f.event_timestamp
      END
    ) AS view_item_time
  FROM session_start_step AS s
  JOIN funnel_data AS f
    ON s.unique_session_id = f.unique_session_id
  GROUP BY
    s.unique_session_id,
    s.session_start_time
),

add_to_cart_step AS (
  SELECT
    v.unique_session_id,
    v.session_start_time,
    v.view_item_time,
    MIN(
      CASE
        WHEN f.event_name = 'add_to_cart'
          AND f.event_timestamp > v.view_item_time
        THEN f.event_timestamp
      END
    ) AS add_to_cart_time
  FROM view_item_step AS v
  JOIN funnel_data AS f
    ON v.unique_session_id = f.unique_session_id
  GROUP BY
    v.unique_session_id,
    v.session_start_time,
    v.view_item_time
),

begin_checkout_step AS (
  SELECT
    a.unique_session_id,
    a.session_start_time,
    a.view_item_time,
    a.add_to_cart_time,
    MIN(
      CASE
        WHEN f.event_name = 'begin_checkout'
          AND f.event_timestamp > a.add_to_cart_time
        THEN f.event_timestamp
      END
    ) AS begin_checkout_time
  FROM add_to_cart_step AS a
  JOIN funnel_data AS f
    ON a.unique_session_id = f.unique_session_id
  GROUP BY
    a.unique_session_id,
    a.session_start_time,
    a.view_item_time,
    a.add_to_cart_time
),

add_shipping_info_step AS (
  SELECT
    b.unique_session_id,
    b.session_start_time,
    b.view_item_time,
    b.add_to_cart_time,
    b.begin_checkout_time,
    MIN(
      CASE
        WHEN f.event_name = 'add_shipping_info'
          AND f.event_timestamp > b.begin_checkout_time
        THEN f.event_timestamp
      END
    ) AS add_shipping_info_time
  FROM begin_checkout_step AS b
  JOIN funnel_data AS f
    ON b.unique_session_id = f.unique_session_id
  GROUP BY
    b.unique_session_id,
    b.session_start_time,
    b.view_item_time,
    b.add_to_cart_time,
    b.begin_checkout_time
),

add_payment_info_step AS (
  SELECT
    sh.unique_session_id,
    sh.session_start_time,
    sh.view_item_time,
    sh.add_to_cart_time,
    sh.begin_checkout_time,
    sh.add_shipping_info_time,
    MIN(
      CASE
        WHEN f.event_name = 'add_payment_info'
          AND f.event_timestamp > sh.add_shipping_info_time
        THEN f.event_timestamp
      END
    ) AS add_payment_info_time
  FROM add_shipping_info_step AS sh
  JOIN funnel_data AS f
    ON sh.unique_session_id = f.unique_session_id
  GROUP BY
    sh.unique_session_id,
    sh.session_start_time,
    sh.view_item_time,
    sh.add_to_cart_time,
    sh.begin_checkout_time,
    sh.add_shipping_info_time
),

purchase_step AS (
  SELECT
    p.unique_session_id,
    p.session_start_time,
    p.view_item_time,
    p.add_to_cart_time,
    p.begin_checkout_time,
    p.add_shipping_info_time,
    p.add_payment_info_time,
    MIN(
      CASE
        WHEN f.event_name = 'purchase'
          AND f.event_timestamp > p.add_payment_info_time
        THEN f.event_timestamp
      END
    ) AS purchase_time
  FROM add_payment_info_step AS p
  JOIN funnel_data AS f
    ON p.unique_session_id = f.unique_session_id
  GROUP BY
    p.unique_session_id,
    p.session_start_time,
    p.view_item_time,
    p.add_to_cart_time,
    p.begin_checkout_time,
    p.add_shipping_info_time,
    p.add_payment_info_time
),

landing_page_data AS (
  SELECT
    CONCAT(
      user_pseudo_id,
      CAST(
        (
          SELECT ep.value.int_value
          FROM UNNEST(event_params) AS ep
          WHERE ep.key = 'ga_session_id'
        ) AS STRING
      )
    ) AS unique_session_id,
    event_timestamp,
    (
      SELECT ep.value.string_value
      FROM UNNEST(event_params) AS ep
      WHERE ep.key = 'page_location'
    ) AS page_location
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name = 'page_view'
    AND _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
),

landing_page_session AS (
  SELECT
    unique_session_id,
    ARRAY_AGG(
      page_location
      ORDER BY event_timestamp
      LIMIT 1
    )[SAFE_OFFSET(0)] AS landing_page
  FROM landing_page_data
  GROUP BY unique_session_id
),

traffic_data AS (
  SELECT
    CONCAT(
      user_pseudo_id,
      CAST(
        (
          SELECT ep.value.int_value
          FROM UNNEST(event_params) AS ep
          WHERE ep.key = 'ga_session_id'
        ) AS STRING
      )
    ) AS unique_session_id,
    event_timestamp,
    (
      SELECT ep.value.string_value
      FROM UNNEST(event_params) AS ep
      WHERE ep.key = 'source'
    ) AS source,
    (
      SELECT ep.value.string_value
      FROM UNNEST(event_params) AS ep
      WHERE ep.key = 'medium'
    ) AS medium,
    (
      SELECT ep.value.string_value
      FROM UNNEST(event_params) AS ep
      WHERE ep.key = 'campaign'
    ) AS campaign
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
),

traffic_session AS (
  SELECT
    unique_session_id,
    ARRAY_AGG(
      source IGNORE NULLS
      ORDER BY event_timestamp
      LIMIT 1
    )[SAFE_OFFSET(0)] AS source,
    ARRAY_AGG(
      medium IGNORE NULLS
      ORDER BY event_timestamp
      LIMIT 1
    )[SAFE_OFFSET(0)] AS medium,
    ARRAY_AGG(
      campaign IGNORE NULLS
      ORDER BY event_timestamp
      LIMIT 1
    )[SAFE_OFFSET(0)] AS campaign
  FROM traffic_data
  GROUP BY unique_session_id
),

device_session AS (
  SELECT
    unique_session_id,
    ANY_VALUE(device_category) AS device_category,
    ANY_VALUE(device_language) AS device_language,
    ANY_VALUE(operating_system) AS operating_system
  FROM (
    SELECT
      CONCAT(
        user_pseudo_id,
        CAST(
          (
            SELECT ep.value.int_value
            FROM UNNEST(event_params) AS ep
            WHERE ep.key = 'ga_session_id'
          ) AS STRING
        )
      ) AS unique_session_id,
      device.category AS device_category,
      device.language AS device_language,
      device.operating_system AS operating_system
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    WHERE event_name = 'session_start'
      AND _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
  )
  GROUP BY unique_session_id
),

revenue_session AS (
  SELECT
    CONCAT(
      user_pseudo_id,
      CAST(
        (
          SELECT ep.value.int_value
          FROM UNNEST(event_params) AS ep
          WHERE ep.key = 'ga_session_id'
        ) AS STRING
      )
    ) AS unique_session_id,
    SUM(ecommerce.purchase_revenue) AS purchase_revenue,
    COUNT(*) AS purchase_event_count
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name = 'purchase'
    AND _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
  GROUP BY unique_session_id
)

SELECT
  p.unique_session_id,
  TIMESTAMP_MICROS(p.session_start_time) AS session_start_datetime,
  DATE(TIMESTAMP_MICROS(p.session_start_time)) AS session_date,
  l.landing_page,
  t.source,
  t.medium,
  t.campaign,
  d.device_category,
  d.device_language,
  d.operating_system,
  r.purchase_revenue,
  r.purchase_event_count,
  TIMESTAMP_MICROS(p.view_item_time) AS view_item_datetime,
  TIMESTAMP_MICROS(p.add_to_cart_time) AS add_to_cart_datetime,
  TIMESTAMP_MICROS(p.begin_checkout_time) AS begin_checkout_datetime,
  TIMESTAMP_MICROS(p.add_shipping_info_time) AS add_shipping_info_datetime,
  TIMESTAMP_MICROS(p.add_payment_info_time) AS add_payment_info_datetime,
  TIMESTAMP_MICROS(p.purchase_time) AS purchase_datetime
FROM purchase_step AS p
LEFT JOIN landing_page_session AS l
  ON p.unique_session_id = l.unique_session_id
LEFT JOIN traffic_session AS t
  ON p.unique_session_id = t.unique_session_id
LEFT JOIN device_session AS d
  ON p.unique_session_id = d.unique_session_id
LEFT JOIN revenue_session AS r
  ON p.unique_session_id = r.unique_session_id
WHERE p.session_start_time IS NOT NULL;
