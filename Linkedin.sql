WITH date_cte AS (
    SELECT '2023-01-01'::DATE AS date
    UNION ALL
    SELECT date + INTERVAL '1 DAY'
    FROM date_cte
    WHERE date < '2024-05-30'
)
,

Followers_Gained AS (
SELECT DATE(DAY) as "Date",
    FOLLOWER_GAINS_ORGANIC_FOLLOWER_GAIN as "Followers_Gained",
    FOLLOWER_GAINS_PAID_FOLLOWER_GAIN as "Paid_Followers_Gained",
    REGEXP_SUBSTR(ORGANIZATION_ENTITY,'[0-9]+') as "ORG_ID"
FROM linkedin.time_bound_follower_statistic
),



ORG_INFO as(
SELECT ID as "ID",
    FOUNDED_ON_YEAR as "Year_Founded",
    LOCALIZED_NAME as "Account",
    localized_website as "URL"
 
FROM LINKEDIN.ORGANIZATION
),



Categories as (SELECT 
-- ID "Post_ID"
 ORGANIZATION_ID 
, DATE(FIRST_PUBLISHED_AT) as "Date"
, SUM(REGEXP_COUNT(COMMENTARY, '@')) "Number of Mentions"
, MAX(CASE WHEN REGEXP_SUBSTR(COMMENTARY, '@') != '' THEN TRUE ELSE FALSE END) "Mention Binary"
, SUM(REGEXP_COUNT(COMMENTARY, 'hashtag')) "Number of Hashtags"
, MAX(CASE WHEN REGEXP_SUBSTR(COMMENTARY, 'hashtag') != '' THEN TRUE ELSE FALSE END) "Hashtag Binary"
, ARRAYAGG (REGEXP_SUBSTR_ALL(COMMENTARY, '#.*}')) "Hashtag List"
, MAX(CASE WHEN REGEXP_SUBSTR(COMMENTARY, 'AI') != '' THEN TRUE ELSE FALSE END) "AI"
, MAX(CASE WHEN REGEXP_SUBSTR(LOWER(COMMENTARY), 'blog') != '' THEN TRUE ELSE FALSE END) "Blog"
, MAX(CASE WHEN REGEXP_SUBSTR(LOWER(COMMENTARY), 'tableau') != '' THEN TRUE ELSE FALSE END) "Tableau"
, MAX(CASE WHEN REGEXP_SUBSTR(LOWER(COMMENTARY), 'alteryx') != '' THEN TRUE ELSE FALSE END )"Alteryx"
, MAX(CASE WHEN REGEXP_SUBSTR(LOWER(COMMENTARY), 'power bi') != '' THEN TRUE ELSE FALSE END )"Power BI"

FROM SQL_HACKATHON.LINKEDIN.UGC_POST_HISTORY


LEFT JOIN linkedin.organization_ugc_post AS G
    ON ID=G.UGC_POST_ID

    GROUP BY  ORGANIZATION_ID 
, DATE(FIRST_PUBLISHED_AT)
--WHERE ID = 'urn:li:ugcPost:7125568990310985728'
)


SELECT DATE(DAY) as "Date",
    REGEXP_SUBSTR(organization_entity,'[0-9]+') as "ORG_ID",
    engagement as "Engagement_Score",
    unique_impressions_count as "Unique_Impressions",
    share_count as "Shares",
    --share_mentions_count as "Mentions",
    click_count as "Clicks",
    like_count as "Likes",
    impression_count as "Impressions",
    comment_count as "Comments",
    I."Account" as "Account",
    F."Followers_Gained" as "Followers_Gained",
   -- F."Paid_Followers_Gained" as "Paid_Followers_Gained"
   C."Number of Mentions",
   C."Mention Binary",
   C."Number of Hashtags",
   C."Hashtag Binary",
   C."Hashtag List",
   C."AI",
   C."Blog",
   C."Tableau",
   C."Alteryx",
   C."Power BI"

   FROM date_cte D
 
JOIN linkedin.time_bound_share_statistic as S
    ON D.date = DATE(S.day)

LEFT JOIN FOLLOWERS_GAINED AS F
    ON DATE(S.DAY) = F."Date"
    AND REGEXP_SUBSTR(S.organization_entity,'[0-9]+') = F."ORG_ID"

LEFT JOIN ORG_INFO AS I
    ON I.ID = F."ORG_ID"

LEFT JOIN Categories AS C
    ON C.Organization_ID = REGEXP_SUBSTR(S.organization_entity,'[0-9]+')
    AND C."Date" = DATE(S.DAY)
;
