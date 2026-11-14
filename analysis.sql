-- ============================================================
-- SET 学生评教数据分析 —— 核心查询
-- 数据库：MySQL 5.7 / set_analysis.set_courses（340 门课程）
-- 用途：用 SQL 复现 R 报告中的关键结论
-- 运行：HeidiSQL 中全选后按 F9
-- ============================================================

USE set_analysis;
SET NAMES utf8mb4;
-- 1. 各职称的平均分（对应报告 2.2）
SELECT title, COUNT(*) AS 课程数, ROUND(AVG(score),3) AS 平均分
FROM set_courses GROUP BY title ORDER BY 平均分 DESC;

-- 2. 各学生类别的班额与平均分（对应 2.4 的混杂发现）
SELECT student, COUNT(*) AS 课程数,
       ROUND(AVG(size),1) AS 平均班额, ROUND(AVG(score),3) AS 平均分
FROM set_courses GROUP BY student;

-- 3. 学期 × 职称交叉表（对应 2.5：春季全是正教授）
SELECT semester,
       SUM(title='副教授')   AS 副教授,
       SUM(title='助理教授') AS 助理教授,
       SUM(title='正教授')   AS 正教授,
       COUNT(*) AS 合计
FROM set_courses GROUP BY semester;

-- 4. 人数分组的平均分（对应 2.3 的 U 型）
SELECT CASE WHEN size<=20  THEN '01-20'
            WHEN size<=35  THEN '21-35'
            WHEN size<=55  THEN '36-55'
            WHEN size<=80  THEN '56-80'
            WHEN size<=100 THEN '81-100'
            ELSE '100+' END AS 人数分组,
       COUNT(*) AS 课程数, ROUND(AVG(score),3) AS 平均分
FROM set_courses GROUP BY 人数分组 ORDER BY MIN(size);

-- 5. 评分最低的 5 门（对应 2.6 里的离群点 219/137/301）
SELECT title, student, year, semester, size, score
FROM set_courses ORDER BY score ASC LIMIT 5;

-- 6. 多条件筛选 + 分组
SELECT title, student, COUNT(*) AS 课程数, ROUND(AVG(score),3) AS 平均分
FROM set_courses
WHERE title IN ('正教授','助理教授')
GROUP BY title, student ORDER BY title, 平均分 DESC;
