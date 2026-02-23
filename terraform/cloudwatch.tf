# Log Group
resource "aws_cloudwatch_log_group" "strapi" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = 7
  tags = { Name = "${var.app_name}-logs" }
}

# CPU Alarm
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.app_name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when CPU exceeds 80%"
  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.strapi.name
  }
}

# Memory Alarm
resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "${var.app_name}-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when Memory exceeds 80%"
  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.strapi.name
  }
}

# ALB 5XX Errors
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.app_name}-alb-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Alert when ALB 5XX errors exceed 10"
  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }
}

# ALB 4XX Errors
resource "aws_cloudwatch_metric_alarm" "alb_4xx" {
  alarm_name          = "${var.app_name}-alb-4xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 50
  alarm_description   = "Alert when ALB 4XX errors exceed 50"
  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }
}

# ALB Target Response Time
resource "aws_cloudwatch_metric_alarm" "alb_response_time" {
  alarm_name          = "${var.app_name}-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 5
  alarm_description   = "Alert when response time exceeds 5 seconds"
  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }
}

# Unhealthy Host Count
resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  alarm_name          = "${var.app_name}-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "Alert when any host is unhealthy"
  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.strapi.arn_suffix
  }
}

# ECS Running Task Count
resource "aws_cloudwatch_metric_alarm" "ecs_running_tasks" {
  alarm_name          = "${var.app_name}-running-tasks"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "Alert when no tasks are running"
  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.strapi.name
  }
}

# Log Metric Filter for Errors
resource "aws_cloudwatch_log_metric_filter" "error_filter" {
  name           = "${var.app_name}-error-filter"
  pattern        = "ERROR"
  log_group_name = aws_cloudwatch_log_group.strapi.name

  metric_transformation {
    name      = "${var.app_name}-error-count"
    namespace = "Strapi/Errors"
    value     = "1"
  }
}

# Alarm for Application Errors
resource "aws_cloudwatch_metric_alarm" "app_errors" {
  alarm_name          = "${var.app_name}-app-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "${var.app_name}-error-count"
  namespace           = "Strapi/Errors"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Alert when app errors exceed 5 in 1 minute"
  treat_missing_data  = "notBreaching"
}

# Log Metric Filter for Fatal Errors
resource "aws_cloudwatch_log_metric_filter" "fatal_filter" {
  name           = "${var.app_name}-fatal-filter"
  pattern        = "FATAL"
  log_group_name = aws_cloudwatch_log_group.strapi.name

  metric_transformation {
    name      = "${var.app_name}-fatal-count"
    namespace = "Strapi/Errors"
    value     = "1"
  }
}

# Alarm for Fatal Errors
resource "aws_cloudwatch_metric_alarm" "fatal_errors" {
  alarm_name          = "${var.app_name}-fatal-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "${var.app_name}-fatal-count"
  namespace           = "Strapi/Errors"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alert immediately when fatal error occurs"
  treat_missing_data  = "notBreaching"
}

# RDS CPU Alarm
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.app_name}-rds-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when RDS CPU exceeds 80%"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres.identifier
  }
}

# RDS Free Storage Alarm
resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  alarm_name          = "${var.app_name}-rds-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 2000000000
  alarm_description   = "Alert when RDS free storage is less than 2GB"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres.identifier
  }
}

# RDS Connections Alarm
resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  alarm_name          = "${var.app_name}-rds-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when RDS connections exceed 80"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres.identifier
  }
}
