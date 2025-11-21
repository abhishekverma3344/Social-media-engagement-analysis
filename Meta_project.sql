-- Q1:Are there any tables with duplicate or missing null values?

-- NULL checks
SELECT * FROM ig_clone.users WHERE username IS NULL;
SELECT * FROM ig_clone.photos WHERE image_url IS NULL OR user_id IS NULL;
SELECT * FROM ig_clone.comments WHERE comment_text IS NULL OR user_id IS NULL OR photo_id IS NULL;
SELECT * FROM ig_clone.likes WHERE user_id IS NULL OR photo_id IS NULL;
SELECT * FROM ig_clone.follows WHERE follower_id IS NULL OR followee_id IS NULL;
SELECT * FROM ig_clone.tags WHERE tag_name IS NULL;
SELECT * FROM ig_clone.photo_tags WHERE photo_id IS NULL OR tag_id IS NULL;

-- Duplicate checks
SELECT username, COUNT(*) AS cnt FROM ig_clone.users GROUP BY username HAVING cnt > 1;
SELECT image_url, COUNT(*) AS cnt FROM ig_clone.photos GROUP BY image_url HAVING cnt > 1;
SELECT user_id, photo_id, comment_text, COUNT(*) AS cnt FROM ig_clone.comments GROUP BY user_id, photo_id, comment_text HAVING cnt > 1;
SELECT user_id, photo_id, COUNT(*) AS cnt FROM ig_clone.likes GROUP BY user_id, photo_id HAVING cnt > 1;
SELECT follower_id, followee_id, COUNT(*) AS cnt FROM ig_clone.follows GROUP BY follower_id, followee_id HAVING cnt > 1;
SELECT tag_name, COUNT(*) AS cnt FROM ig_clone.tags GROUP BY tag_name HAVING cnt > 1;
SELECT photo_id, tag_id, COUNT(*) AS cnt FROM ig_clone.photo_tags GROUP BY photo_id, tag_id HAVING cnt > 1;

-- Q2: What is the distribution of user activity levels (number of posts, likes given, and comments made) for each user?

SELECT
    u.username,
    COUNT(DISTINCT p.id) AS num_posts,
    COUNT(DISTINCT l.photo_id) AS num_likes,
    COUNT(DISTINCT c.id) AS num_comments
FROM
    ig_clone.users u
LEFT JOIN
    ig_clone.photos p ON u.id = p.user_id
LEFT JOIN
    ig_clone.likes l ON u.id = l.user_id
LEFT JOIN
    ig_clone.comments c ON u.id = c.user_id
GROUP BY
    u.username
ORDER BY
    num_posts DESC, num_likes DESC, num_comments DESC;
    
-- Q3: Calculate the average number of tags per post (photo_tags and photos tables)

SELECT ROUND(AVG(tag_count), 2) AS avg_tags_per_post
FROM (
  SELECT p.id, COUNT(pt.tag_id) AS tag_count
  FROM ig_clone.photos p
  LEFT JOIN ig_clone.photo_tags pt ON p.id = pt.photo_id
  GROUP BY p.id
) t;

-- Q4: Identify the top users with the highest engagement rates (likes + comments on their posts) and rank them

SELECT 
  u.id,
  u.username,
  COUNT(DISTINCT l.user_id) AS total_likes,
  COUNT(DISTINCT c.id) AS total_comments,
  (COUNT(DISTINCT l.user_id) + COUNT(DISTINCT c.id)) AS total_engagement
FROM ig_clone.users u
JOIN ig_clone.photos p ON u.id = p.user_id
LEFT JOIN ig_clone.likes l ON p.id = l.photo_id
LEFT JOIN ig_clone.comments c ON p.id = c.photo_id
GROUP BY u.id, u.username
ORDER BY total_engagement DESC
LIMIT 10;

-- Q5: Which users have the highest number of followers and followings?

-- Highest followers
SELECT
    u.username,
    COUNT(f.follower_id) AS num_followers
FROM ig_clone.users u
JOIN ig_clone.follows f ON u.id = f.followee_id
GROUP BY u.username
ORDER BY num_followers DESC
LIMIT 10;

-- Highest followings
SELECT
    u.username,
    COUNT(f.followee_id) AS num_followings
FROM ig_clone.users u
JOIN ig_clone.follows f ON u.id = f.follower_id
GROUP BY u.username
ORDER BY num_followings DESC
LIMIT 10;

-- Q6: Calculate average engagement rate (likes + comments) per post for each user
-- engagement_rate = (total_likes_on_user_posts + total_comments_on_user_posts) / total_posts
SELECT
    u.username,
    (COUNT(DISTINCT l.photo_id) + COUNT(DISTINCT c.id)) AS total_engagement,   -- likes + comments on user's posts
    COUNT(DISTINCT p.id) AS total_posts,                                      -- number of posts by user
    (COUNT(DISTINCT l.photo_id) + COUNT(DISTINCT c.id))                       -- numerator
      / NULLIF(COUNT(DISTINCT p.id), 0) AS engagement_rate                    -- divide by posts, NULL if 0 posts
FROM
    ig_clone.users u
JOIN
    ig_clone.photos p ON u.id = p.user_id
LEFT JOIN
    ig_clone.likes l ON p.id = l.photo_id
LEFT JOIN
    ig_clone.comments c ON p.id = c.photo_id
GROUP BY
    u.username
ORDER BY
    engagement_rate DESC;
    
-- Q7: Get the list of users who have never liked any post (users and likes tables)
SELECT
    u.username
FROM
    ig_clone.users u
LEFT JOIN
    ig_clone.likes l ON u.id = l.user_id
WHERE
    l.user_id IS NULL;
    
-- Q8. How can you leverage user-generated content (posts, hashtags, photo tags) to create more personalized and engaging ad campaigns?
-- Top 20 tags by usage (helps find themes to target)
SELECT t.tag_name, COUNT(pt.photo_id) AS tag_usage
FROM ig_clone.tags t
JOIN ig_clone.photo_tags pt ON t.id = pt.tag_id
GROUP BY t.tag_name
ORDER BY tag_usage DESC
LIMIT 20;

-- Top posts by highest engagement
SELECT
    u.username,
    COUNT(DISTINCT l.user_id) AS total_likes_received,
    COUNT(DISTINCT c.id) AS total_comments_received,
    COUNT(DISTINCT p.id) AS total_posts,
    (COUNT(DISTINCT l.user_id) + COUNT(DISTINCT c.id)) / COUNT(DISTINCT p.id) AS engagement_rate
FROM
    ig_clone.users u
JOIN
    ig_clone.photos p ON u.id = p.user_id
LEFT JOIN
    ig_clone.likes l ON p.id = l.photo_id
LEFT JOIN
    ig_clone.comments c ON p.id = c.photo_id
GROUP BY
    u.username
ORDER BY
    engagement_rate DESC;

-- Users who frequently post a tag (good for creator outreach)
SELECT u.username, COUNT(p.id) AS posts_with_tag
FROM ig_clone.users u
JOIN ig_clone.photos p ON u.id = p.user_id
JOIN ig_clone.photo_tags pt ON p.id = pt.photo_id
JOIN ig_clone.tags t ON pt.tag_id = t.id
WHERE t.tag_name = 'food'
GROUP BY u.username
ORDER BY posts_with_tag DESC
LIMIT 20;

-- Q9: Are there any correlations between user activity levels and specific content types (e.g., photos, videos, reels)?
SELECT 
    u.id AS user_id,
    u.username,
    COUNT(DISTINCT p.id) AS total_photos_posted,
    COUNT(DISTINCT l.photo_id) AS total_likes_given,
    COUNT(DISTINCT c.id) AS total_comments_made,
    (
        SELECT COUNT(*) 
        FROM ig_clone.likes l2
        JOIN ig_clone.photos p2 ON l2.photo_id = p2.id
        WHERE p2.user_id = u.id
    ) AS total_likes_received,
    (
        SELECT COUNT(*) 
        FROM ig_clone.comments c2
        JOIN ig_clone.photos p2 ON c2.photo_id = p2.id
        WHERE p2.user_id = u.id
    ) AS total_comments_received
FROM ig_clone.users u
LEFT JOIN ig_clone.photos p ON u.id = p.user_id
LEFT JOIN ig_clone.likes l ON u.id = l.user_id
LEFT JOIN ig_clone.comments c ON u.id = c.user_id
GROUP BY u.id, u.username
HAVING COUNT(DISTINCT p.id) > 0
ORDER BY total_photos_posted DESC;

-- Q10: Calculate the total number of likes, comments, and photo tags for each user.

SELECT
    u.username,
    COUNT(DISTINCT p.id) AS total_posts,
    COUNT(l.photo_id) AS total_likes_received,      
    COUNT(c.id) AS total_comments_received,           
    ROUND(
        (COUNT(l.photo_id) + COUNT(c.id)) * 1.0 /
        NULLIF(COUNT(DISTINCT p.id), 0), 2
    ) AS engagement_rate
FROM ig_clone.users u
LEFT JOIN ig_clone.photos p ON u.id = p.user_id
LEFT JOIN ig_clone.likes l ON l.photo_id = p.id
LEFT JOIN ig_clone.comments c ON c.photo_id = p.id
GROUP BY u.username
ORDER BY engagement_rate DESC
LIMIT 10;
  
-- Q12: Retrieve the hashtags that have been used in posts with the highest average number of likes. Use a CTE to calculate the average likes for each hashtag first.

WITH photo_likes AS (
    SELECT
        photo_id,
        COUNT(*) AS like_count
    FROM
        ig_clone.likes
    GROUP BY
        photo_id
)
SELECT
    t.tag_name,
    AVG(pl.like_count) AS avg_likes_per_tag
FROM
    ig_clone.photo_tags pt
JOIN
    photo_likes pl ON pt.photo_id = pl.photo_id
JOIN
    ig_clone.tags t ON pt.tag_id = t.id
GROUP BY
    t.tag_name
ORDER BY
    avg_likes_per_tag DESC
LIMIT 10;
    
-- Q13: Retrieve the users who have started following someone after being followed by that person (mutual follow-back)

SELECT 
  f1.follower_id       AS user_id,
  f1.followee_id       AS followed_back_user,
  f1.created_at        AS followed_at,
  f2.created_at        AS was_followed_at
FROM ig_clone.follows f1
JOIN ig_clone.follows f2 
  ON f1.follower_id = f2.followee_id 
  AND f1.followee_id = f2.follower_id
WHERE 
  f1.follower_id <> f1.followee_id    -- avoid self-follow
  AND f1.created_at >= f2.created_at   -- followed AFTER being followed, or at the same time
ORDER BY f1.created_at
LIMIT 10;

-- Subjective Q1: Top 10 users by a simple loyalty_score (weighted)
SELECT
  u.username,
  COALESCE(p.total_posts, 0)                    AS total_posts,
  COALESCE(l.total_likes, 0)                    AS total_likes,
  ROUND(COALESCE(l.total_likes, 0) / NULLIF(p.total_posts, 0), 2) AS avg_likes_per_post,
  COALESCE(c.total_comments, 0)                 AS total_comments,
  ROUND(COALESCE(c.total_comments, 0) / NULLIF(p.total_posts, 0), 2) AS avg_comments_per_post,
  COALESCE(f.total_followers, 0)                AS total_followers,
  -- loyalty_score = 2*posts + 1.5*comments + 1*likes + 0.5*followers
  ROUND(
    (COALESCE(p.total_posts,0) * 2.0)
    + (COALESCE(c.total_comments,0) * 1.5)
    + (COALESCE(l.total_likes,0) * 1.0)
    + (COALESCE(f.total_followers,0) * 0.5)
  ,2) AS loyalty_score
FROM ig_clone.users u
LEFT JOIN (
    SELECT user_id, COUNT(*) AS total_posts
    FROM ig_clone.photos
    GROUP BY user_id
) p ON u.id = p.user_id
LEFT JOIN (
    SELECT p.user_id, COUNT(*) AS total_likes
    FROM ig_clone.photos p
    JOIN ig_clone.likes l ON p.id = l.photo_id
    GROUP BY p.user_id
) l ON u.id = l.user_id
LEFT JOIN (
    SELECT p.user_id, COUNT(*) AS total_comments
    FROM ig_clone.photos p
    JOIN ig_clone.comments c ON p.id = c.photo_id
    GROUP BY p.user_id
) c ON u.id = c.user_id
LEFT JOIN (
    SELECT followee_id AS user_id, COUNT(*) AS total_followers
    FROM ig_clone.follows
    GROUP BY followee_id
) f ON u.id = f.user_id
ORDER BY loyalty_score DESC
LIMIT 10;

-- Subjective Question 2: Fetch list of inactive users (no posts, no likes given, no comments made)
SELECT
  u.username
FROM ig_clone.users u
LEFT JOIN ig_clone.photos p   ON u.id = p.user_id
LEFT JOIN ig_clone.likes l    ON u.id = l.user_id
LEFT JOIN ig_clone.comments c ON u.id = c.user_id
GROUP BY u.id, u.username
HAVING COUNT(p.id) = 0
   AND COUNT(l.photo_id) = 0
   AND COUNT(c.id) = 0;

-- Subjective Q3: Top 10 hashtags by average engagement (likes + comments per post)

WITH photo_likes AS (
    -- 1. Pre-aggregate the total likes for each photo
    SELECT
        photo_id,
        COUNT(photo_id) AS like_count
    FROM
        ig_clone.likes
    GROUP BY
        photo_id
),
photo_comments AS (
    -- 2. Pre-aggregate the total comments for each photo
    SELECT
        photo_id,
        COUNT(id) AS comment_count
    FROM
        ig_clone.comments
    GROUP BY
        photo_id
)
SELECT
    t.tag_name,
    -- 3. Calculate the Average Likes per Tag (using pre-aggregated counts)
    ROUND(AVG(pl.like_count), 2) AS avg_likes_per_post,
    -- 4. Calculate the Average Comments per Tag (using pre-aggregated counts)
    ROUND(AVG(pc.comment_count), 2) AS avg_comments_per_post
FROM
    ig_clone.tags t
JOIN
    ig_clone.photo_tags pt ON t.id = pt.tag_id
-- LEFT JOIN the pre-aggregated like counts
LEFT JOIN
    photo_likes pl ON pt.photo_id = pl.photo_id
-- LEFT JOIN the pre-aggregated comment counts
LEFT JOIN
    photo_comments pc ON pt.photo_id = pc.photo_id
GROUP BY
    t.tag_name
ORDER BY
    (AVG(pl.like_count) + AVG(pc.comment_count)) DESC -- Order by combined average engagement
LIMIT 10;


-- Subjective Question 4: Find posting trends by hour of the day
SELECT 
  HOUR(p.created_dat) AS post_hour,
  COUNT(DISTINCT l.user_id) AS likes,
  COUNT(DISTINCT c.id) AS comments
FROM ig_clone.photos p
JOIN ig_clone.users u ON p.user_id = u.id
LEFT JOIN ig_clone.likes l ON p.id = l.photo_id
LEFT JOIN ig_clone.comments c ON p.id = c.photo_id
GROUP BY post_hour
ORDER BY post_hour;
-- Subjective question 6
SELECT
    u.username,
    COUNT(DISTINCT p.id) AS num_posts,
    COUNT(DISTINCT l.photo_id) AS num_likes,
    COUNT(DISTINCT c.id) AS num_comments
FROM ig_clone.users u
LEFT JOIN ig_clone.photos p ON u.id = p.user_id
LEFT JOIN ig_clone.likes l ON u.id = l.user_id
LEFT JOIN ig_clone.comments c ON u.id = c.user_id
GROUP BY u.username
ORDER BY num_posts DESC, num_likes DESC, num_comments DESC;
Total Engagement by User Query:
SELECT
    u.username,
    COUNT(DISTINCT l.photo_id) AS total_likes,
    COUNT(DISTINCT c.id) AS total_comments,
    COUNT(DISTINCT pt.tag_id) AS total_tags
FROM ig_clone.users u
LEFT JOIN ig_clone.photos p ON u.id = p.user_id
LEFT JOIN ig_clone.likes l ON p.id = l.photo_id
LEFT JOIN ig_clone.comments c ON p.id = c.photo_id
LEFT JOIN ig_clone.photo_tags pt ON p.id = pt.photo_id
GROUP BY u.username
ORDER BY total_likes DESC, total_comments DESC, total_tags DESC;

-- Subjective Question 7: Top creators with posts, engagement metrics and their most-used tag
SELECT
  u.username,
  COUNT(DISTINCT p.id)                                      AS total_posts,
  COUNT(l.photo_id)                                         AS total_likes,
  COUNT(c.id)                                               AS total_comments,
  (COUNT(l.photo_id) + COUNT(c.id))                         AS total_engagement,
  ROUND((COUNT(l.photo_id) + COUNT(c.id)) / NULLIF(COUNT(DISTINCT p.id),0), 2) AS avg_engagement_per_post,
  (
    SELECT t.tag_name
    FROM ig_clone.photo_tags pt
    JOIN ig_clone.tags t ON pt.tag_id = t.id
    JOIN ig_clone.photos p2 ON pt.photo_id = p2.id
    WHERE p2.user_id = u.id
    GROUP BY t.tag_name
    ORDER BY COUNT(*) DESC
    LIMIT 1
  ) AS top_tag
FROM ig_clone.users u
LEFT JOIN ig_clone.photos p  ON p.user_id = u.id
LEFT JOIN ig_clone.likes l   ON l.photo_id = p.id
LEFT JOIN ig_clone.comments c ON c.photo_id = p.id
GROUP BY u.id, u.username
ORDER BY total_engagement DESC
LIMIT 10;


-- Subjective Question 8: Identify potential brand ambassadors/advocates
SELECT
  u.username,
  COUNT(DISTINCT p.id)                                      AS total_posts,
  (COUNT(l.photo_id) + COUNT(c.id))                         AS total_engagement,
  ROUND((COUNT(l.photo_id) + COUNT(c.id)) / NULLIF(COUNT(DISTINCT p.id),0), 2) AS avg_engagement_per_post,
  (
    SELECT t.tag_name
    FROM ig_clone.photo_tags pt
    JOIN ig_clone.tags t ON pt.tag_id = t.id
    JOIN ig_clone.photos p2 ON pt.photo_id = p2.id
    WHERE p2.user_id = u.id
    GROUP BY t.tag_name
    ORDER BY COUNT(*) DESC
    LIMIT 1
  ) AS top_tag
FROM ig_clone.users u
LEFT JOIN ig_clone.photos p  ON u.id = p.user_id
LEFT JOIN ig_clone.likes l   ON p.id = l.photo_id
LEFT JOIN ig_clone.comments c ON c.photo_id = p.id
GROUP BY u.id, u.username
HAVING total_posts > 0
ORDER BY total_engagement DESC, avg_engagement_per_post desc
LIMIT 10;

