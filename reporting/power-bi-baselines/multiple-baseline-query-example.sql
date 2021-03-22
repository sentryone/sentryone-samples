/*
  Melissa Connors
  https://www.sentryone.com/blog/melissaconnors/multiple-baselines-power-bi
*/

USE [SentryOne]
SELECT Baseline = b.Name,
	Metric = c.Name,
	c.Average,
	c.[Min],
	c.[Max],
	c.StandardDeviation,
	b.RangeStartTime
  FROM [dbo].[PerformanceAnalysisBaselineCounterMapping] c
  JOIN [dbo].[PerformanceAnalysisBaselineChartArea] ca ON c.ChartAreaID = ca.ID
  JOIN [dbo].[PerformanceAnalysisBaseline] b ON ca.BaselineID = b.ID
  ORDER BY c.Name, b.Name, b.RangeStartTime;
