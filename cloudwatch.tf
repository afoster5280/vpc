#===========================================================================#
#                  Cloudwatch Log Group For Cloudwatch Alarm
#===========================================================================#

resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name = "${var.prefix}-cloudwatch-log-group"
}

#===========================================================================#
#                      SNS Topic For Cloudwatch Alarm
#===========================================================================#

resource "aws_sns_topic" "metric_sns" {
  name = "${var.prefix}-metric-sns"
}

resource "aws_sqs_queue" "sqs_metric_sns" {
  name = "${var.prefix}-sqs-metric-sns"
}

resource "aws_sns_topic_subscription" "metric_sns_subscription" {
  topic_arn = "${aws_sns_topic.metric_sns.arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.sqs_metric_sns.arn}"
}

# Contains resources and outputs related to testing the aws_cloudwatch_* resources.

#======================================================#
#                    Log Metric Filters
#======================================================#

# pattern = '{ ($.errorCode = "*UnauthorizedOperation") || ($.errorCode = "AccessDenied*") }'

resource "aws_cloudwatch_log_metric_filter" "unauthorized_api_calls_metric" {
  name = "unauthorized_api_calls_metric"

  pattern = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }"

  log_group_name = "${aws_cloudwatch_log_group.cloudwatch_log_group.name}"

  metric_transformation {
    name      = "unauthorized_api_calls_metric"
    namespace = "CISBenchmark"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "unauthorized_api_calls_alarm" {
  alarm_name          = "unauthorized_api_calls_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "unauthorized_api_calls_metric"
  namespace           = "CISBenchmark"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"

  alarm_actions = ["${aws_sns_topic.metric_sns.arn}"]
}

# pattern = "{ ($.eventName = \"ConsoleLogin\") && ($.additionalEventData.MFAUsed != \"Yes\") }"

resource "aws_cloudwatch_log_metric_filter" "no_mfa_console_signin_metric" {
  name = "no_mfa_console_signin_metric"

  pattern = "{ ($.eventName = \"ConsoleLogin\") && ($.additionalEventData.MFAUsed != \"Yes\") }"

  log_group_name = "${aws_cloudwatch_log_group.cloudwatch_log_group.name}"

  metric_transformation {
    name      = "no_mfa_console_signin_metric"
    namespace = "CISBenchmark"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "no_mfa_console_signin_alarm" {
  alarm_name          = "no_mfa_console_signin_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "no_mfa_console_signin_metric"
  namespace           = "CISBenchmark"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"

  alarm_actions = ["${aws_sns_topic.metric_sns.arn}"]
}

# pattern = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"

resource "aws_cloudwatch_log_metric_filter" "root_usage_metric" {
  name = "root_usage_metric"

  pattern = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"

  log_group_name = "${aws_cloudwatch_log_group.cloudwatch_log_group.name}"

  metric_transformation {
    name      = "root_usage_metric"
    namespace = "CISBenchmark"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "root_usage_alarm" {
  alarm_name          = "root_usage_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "root_usage_metric"
  namespace           = "CISBenchmark"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"

  alarm_actions = ["${aws_sns_topic.metric_sns.arn}"]
}

# pattern = "{ ($.eventName=DeleteGroupPolicy)||($.eventName=DeleteRolePolicy)||($.eventName=DeleteUserPolicy)||($.eventName=PutGroupPolicy)||($.eventName=PutRolePolicy)||($.eventName=PutUserPolicy)||($.eventName=CreatePolicy)||($.eventName=DeletePolicy)||($.eventName=CreatePolicyVersion)||($.eventName=DeletePolicyVersion)||($.eventName=AttachRolePolicy)||($.eventName=DetachRolePolicy)||($.eventName=AttachUserPolicy)||($.eventName=DetachUserPolicy)||($.eventName=AttachGroupPolicy)||($.eventName=DetachGroupPolicy)}"

resource "aws_cloudwatch_log_metric_filter" "iam_changes_metric" {
  name = "iam_changes_metric"

  pattern = "{ ($.eventName=DeleteGroupPolicy)||($.eventName=DeleteRolePolicy)||($.eventName=DeleteUserPolicy)||($.eventName=PutGroupPolicy)||($.eventName=PutRolePolicy)||($.eventName=PutUserPolicy)||($.eventName=CreatePolicy)||($.eventName=DeletePolicy)||($.eventName=CreatePolicyVersion)||($.eventName=DeletePolicyVersion)||($.eventName=AttachRolePolicy)||($.eventName=DetachRolePolicy)||($.eventName=AttachUserPolicy)||($.eventName=DetachUserPolicy)||($.eventName=AttachGroupPolicy)||($.eventName=DetachGroupPolicy) }"

  log_group_name = "${aws_cloudwatch_log_group.cloudwatch_log_group.name}"

  metric_transformation {
    name      = "iam_changes_metric"
    namespace = "CISBenchmark"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "iam_changes_alarm" {
  alarm_name          = "iam_changes_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "iam_changes_metric"
  namespace           = "CISBenchmark"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"

  alarm_actions = ["${aws_sns_topic.metric_sns.arn}"]
}

# pattern = "{ ($.eventName = CreateTrail) || ($.eventName = UpdateTrail) || ($.eventName = DeleteTrail) || ($.eventName = StartLogging) || ($.eventName = StopLogging) }"

resource "aws_cloudwatch_log_metric_filter" "cloudtrail_cfg_changes_metric" {
  name = "cloudtrail_cfg_changes_metric"

  pattern = "{ ($.eventName = CreateTrail) || ($.eventName = UpdateTrail) || ($.eventName = DeleteTrail) || ($.eventName = StartLogging) || ($.eventName = StopLogging) }"

  log_group_name = "${aws_cloudwatch_log_group.cloudwatch_log_group.name}"

  metric_transformation {
    name      = "cloudtrail_cfg_changes_metric"
    namespace = "CISBenchmark"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudtrail_cfg_changes_alarm" {
  alarm_name          = "cloudtrail_cfg_changes_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "cloudtrail_cfg_changes_metric"
  namespace           = "CISBenchmark"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"

  alarm_actions = ["${aws_sns_topic.metric_sns.arn}"]
}

# pattern = "{ ($.eventName = ConsoleLogin) && ($.errorMessage = \"Failed authentication\") }"

resource "aws_cloudwatch_log_metric_filter" "console_signin_failure_metric" {
  name = "console_signin_failure_metric"

  pattern = "{ ($.eventName = ConsoleLogin) && ($.errorMessage = \"Failed authentication\") }"

  log_group_name = "${aws_cloudwatch_log_group.cloudwatch_log_group.name}"

  metric_transformation {
    name      = "console_signin_failure_metric"
    namespace = "CISBenchmark"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "console_signin_failure_alarm" {
  alarm_name          = "console_signin_failure_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "console_signin_failure_metric"
  namespace           = "CISBenchmark"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"

  alarm_actions = ["${aws_sns_topic.metric_sns.arn}"]
}

# pattern = "{ ($.eventSource = kms.amazonaws.com) && (($.eventName=DisableKey)||($.eventName=ScheduleKeyDeletion))}"

resource "aws_cloudwatch_log_metric_filter" "disable_or_delete_cmk_metric" {
  name = "disable_or_delete_cmk_metric"

  pattern = "{ ($.eventSource = kms.amazonaws.com) && (($.eventName = DisableKey) || ($.eventName = ScheduleKeyDeletion)) }"

  log_group_name = "${aws_cloudwatch_log_group.cloudwatch_log_group.name}"

  metric_transformation {
    name      = "disable_or_delete_cmk_metric"
    namespace = "CISBenchmark"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "disable_or_delete_cmk_alarm" {
  alarm_name          = "disable_or_delete_cmk_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "disable_or_delete_cmk_metric"
  namespace           = "CISBenchmark"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"

  alarm_actions = ["${aws_sns_topic.metric_sns.arn}"]
}

# pattern = "{ ($.eventSource = s3.amazonaws.com) && (($.eventName = PutBucketAcl) || ($.eventName = PutBucketPolicy) || ($.eventName = PutBucketCors) || ($.eventName = PutBucketLifecycle) || ($.eventName = PutBucketReplication) || ($.eventName = DeleteBucketPolicy) || ($.eventName = DeleteBucketCors) || ($.eventName = DeleteBucketLifecycle) || ($.eventName = DeleteBucketReplication)) }"

resource "aws_cloudwatch_log_metric_filter" "s3_bucket_policy_changes_metric" {
  name = "s3_bucket_policy_changes_metric"

  pattern = "{ ($.eventSource = s3.amazonaws.com) && (($.eventName = PutBucketAcl) || ($.eventName = PutBucketPolicy) || ($.eventName = PutBucketCors) || ($.eventName = PutBucketLifecycle) || ($.eventName = PutBucketReplication) || ($.eventName = DeleteBucketPolicy) || ($.eventName = DeleteBucketCors) || ($.eventName = DeleteBucketLifecycle) || ($.eventName = DeleteBucketReplication)) }"

  log_group_name = "${aws_cloudwatch_log_group.cloudwatch_log_group.name}"

  metric_transformation {
    name      = "s3_bucket_policy_changes_metric"
    namespace = "CISBenchmark"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "s3_bucket_policy_changes_alarm" {
  alarm_name          = "s3_bucket_policy_changes_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "s3_bucket_policy_changes_metric"
  namespace           = "CISBenchmark"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"

  alarm_actions = ["${aws_sns_topic.metric_sns.arn}"]
}

# pattern = "{ ($.eventSource = config.amazonaws.com) && (($.eventName=StopConfigurationRecorder)||($.eventName=DeleteDeliveryChannel)||($.eventName=PutDeliveryChannel)||($.eventName=PutConfigurationRecorder))}"

resource "aws_cloudwatch_log_metric_filter" "aws_config_changes_metric" {
  name = "aws_config_changes_metric"

  pattern = "{ ($.eventSource = config.amazonaws.com) && (($.eventName=StopConfigurationRecorder)||($.eventName=DeleteDeliveryChannel)||($.eventName=PutDeliveryChannel)||($.eventName=PutConfigurationRecorder))}"

  log_group_name = "${aws_cloudwatch_log_group.cloudwatch_log_group.name}"

  metric_transformation {
    name      = "aws_config_changes_metric"
    namespace = "CISBenchmark"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "aws_config_changes_alarm" {
  alarm_name          = "aws_config_changes_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "aws_config_changes_metric"
  namespace           = "CISBenchmark"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"

  alarm_actions = ["${aws_sns_topic.metric_sns.arn}"]
}

# pattern = "{ ($.eventName = AuthorizeSecurityGroupIngress) || ($.eventName = AuthorizeSecurityGroupEgress) || ($.eventName = RevokeSecurityGroupIngress) || ($.eventName = RevokeSecurityGroupEgress) || ($.eventName = CreateSecurityGroup) || ($.eventName = DeleteSecurityGroup)}"

resource "aws_cloudwatch_log_metric_filter" "security_group_changes_metric" {
  name = "security_group_changes_metric"

  pattern = "{ ($.eventName = AuthorizeSecurityGroupIngress) || ($.eventName = AuthorizeSecurityGroupEgress) || ($.eventName = RevokeSecurityGroupIngress) || ($.eventName = RevokeSecurityGroupEgress) || ($.eventName = CreateSecurityGroup) || ($.eventName = DeleteSecurityGroup) }"

  log_group_name = "${aws_cloudwatch_log_group.cloudwatch_log_group.name}"

  metric_transformation {
    name      = "security_group_changes_metric"
    namespace = "CISBenchmark"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "security_group_changes_alarm" {
  alarm_name          = "security_group_changes_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "security_group_changes_metric"
  namespace           = "CISBenchmark"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"

  alarm_actions = ["${aws_sns_topic.metric_sns.arn}"]
}

# pattern = "{ ($.eventName = CreateNetworkAcl) || ($.eventName = CreateNetworkAclEntry) || ($.eventName = DeleteNetworkAcl) || ($.eventName = DeleteNetworkAclEntry) || ($.eventName = ReplaceNetworkAclEntry) || ($.eventName = ReplaceNetworkAclAssociation) }"

resource "aws_cloudwatch_log_metric_filter" "nacl_changes_metric" {
  name = "nacl_changes_metric"

  pattern = "{ ($.eventName = CreateNetworkAcl) || ($.eventName = CreateNetworkAclEntry) || ($.eventName = DeleteNetworkAcl) || ($.eventName = DeleteNetworkAclEntry) || ($.eventName = ReplaceNetworkAclEntry) || ($.eventName = ReplaceNetworkAclAssociation) }"

  log_group_name = "${aws_cloudwatch_log_group.cloudwatch_log_group.name}"

  metric_transformation {
    name      = "nacl_changes_metric"
    namespace = "CISBenchmark"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "nacl_changes_alarm" {
  alarm_name          = "nacl_changes_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "nacl_changes_metric"
  namespace           = "CISBenchmark"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"

  alarm_actions = ["${aws_sns_topic.metric_sns.arn}"]
}

# pattern = "{ ($.eventName = CreateCustomerGateway) || ($.eventName = DeleteCustomerGateway) || ($.eventName = AttachInternetGateway) || ($.eventName = CreateInternetGateway) || ($.eventName = DeleteInternetGateway) || ($.eventName = DetachInternetGateway) }"

resource "aws_cloudwatch_log_metric_filter" "network_gw_changes_metric" {
  name = "network_gw_changes_metric"

  pattern = "{ ($.eventName = CreateCustomerGateway) || ($.eventName = DeleteCustomerGateway) || ($.eventName = AttachInternetGateway) || ($.eventName = CreateInternetGateway) || ($.eventName = DeleteInternetGateway) || ($.eventName = DetachInternetGateway) }"

  log_group_name = "${aws_cloudwatch_log_group.cloudwatch_log_group.name}"

  metric_transformation {
    name      = "network_gw_changes_metric"
    namespace = "CISBenchmark"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "network_gw_changes_alarm" {
  alarm_name          = "network_gw_changes_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "network_gw_changes_metric"
  namespace           = "CISBenchmark"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"

  alarm_actions = ["${aws_sns_topic.metric_sns.arn}"]
}

# pattern = "{ ($.eventName = CreateRoute) || ($.eventName = CreateRouteTable) || ($.eventName = ReplaceRoute) || ($.eventName = ReplaceRouteTableAssociation) || ($.eventName = DeleteRouteTable) || ($.eventName = DeleteRoute) || ($.eventName = DisassociateRouteTable) }"

resource "aws_cloudwatch_log_metric_filter" "route_table_changes_metric" {
  name = "route_table_changes_metric"

  pattern = "{ ($.eventName = CreateRoute) || ($.eventName = CreateRouteTable) || ($.eventName = ReplaceRoute) || ($.eventName = ReplaceRouteTableAssociation) || ($.eventName = DeleteRouteTable) || ($.eventName = DeleteRoute) || ($.eventName = DisassociateRouteTable) }"

  log_group_name = "${aws_cloudwatch_log_group.cloudwatch_log_group.name}"

  metric_transformation {
    name      = "route_table_changes_metric"
    namespace = "CISBenchmark"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "route_table_changes_alarm" {
  alarm_name          = "route_table_changes_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "route_table_changes_metric"
  namespace           = "CISBenchmark"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"

  alarm_actions = ["${aws_sns_topic.metric_sns.arn}"]
}

# pattern = "{ ($.eventName = CreateVpc) || ($.eventName = DeleteVpc) || ($.eventName = ModifyVpcAttribute) || ($.eventName = AcceptVpcPeeringConnection) || ($.eventName = CreateVpcPeeringConnection) || ($.eventName = DeleteVpcPeeringConnection) || ($.eventName = RejectVpcPeeringConnection) || ($.eventName = AttachClassicLinkVpc) || ($.eventName = DetachClassicLinkVpc) || ($.eventName = DisableVpcClassicLink) || ($.eventName = EnableVpcClassicLink) }"

resource "aws_cloudwatch_log_metric_filter" "vpc_changes_metric" {
  name = "vpc_changes_metric"

  pattern = "{ ($.eventName = CreateVpc) || ($.eventName = DeleteVpc) || ($.eventName = ModifyVpcAttribute) || ($.eventName = AcceptVpcPeeringConnection) || ($.eventName = CreateVpcPeeringConnection) || ($.eventName = DeleteVpcPeeringConnection) || ($.eventName = RejectVpcPeeringConnection) || ($.eventName = AttachClassicLinkVpc) || ($.eventName = DetachClassicLinkVpc) || ($.eventName = DisableVpcClassicLink) || ($.eventName = EnableVpcClassicLink) }"

  log_group_name = "${aws_cloudwatch_log_group.cloudwatch_log_group.name}"

  metric_transformation {
    name      = "vpc_changes_metric"
    namespace = "CISBenchmark"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "vpc_changes_alarm" {
  alarm_name          = "vpc_changes_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "vpc_changes_metric"
  namespace           = "CISBenchmark"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"

  alarm_actions = ["${aws_sns_topic.metric_sns.arn}"]
}