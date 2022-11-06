resource "aws_s3_bucket" "cloudtrail_bucket_access_log_bucket" {
  bucket_prefix = "${var.prefix}-cloudtrail-access-log-bucket-"
  force_destroy = true
  acl           = "log-delivery-write"
}

resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket_prefix = "${var.prefix}-cloudtrail-bucket-"
  force_destroy = true

  logging {
    target_bucket = "${aws_s3_bucket.cloudtrail_bucket_access_log_bucket.id}"
    target_prefix = "log/"
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = "${aws_s3_bucket.cloudtrail_bucket.id}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.cloudtrail_bucket.id}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.cloudtrail_bucket.id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_iam_role" "cloud_watch_logs_role" {
  name = "${var.prefix}-cloud-watch-logs-role"

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Sid": "",
          "Effect": "Allow",
          "Principal": {
            "Service": "cloudtrail.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy" "cloud_watch_logs_role_policy" {
  depends_on = ["aws_iam_role.cloud_watch_logs_role"]

  name = "${var.prefix}-cloud-watch-logs-role-policy"
  role = "${var.prefix}-cloud-watch-logs-role"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailCreateLogStream",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream"
            ],
            "Resource": [
                "arn:aws:logs:${data.aws_region.region.name}:${data.aws_caller_identity.creds.account_id}:log-group:${aws_cloudwatch_log_group.cloudwatch_log_group.name}:log-stream:${data.aws_caller_identity.creds.account_id}_CloudTrail_${data.aws_region.region.name}*"
            ]
        },
        {
            "Sid": "AWSCloudTrailPutLogEvents",
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${data.aws_region.region.name}:${data.aws_caller_identity.creds.account_id}:log-group:${aws_cloudwatch_log_group.cloudwatch_log_group.name}:log-stream:${data.aws_caller_identity.creds.account_id}_CloudTrail_${data.aws_region.region.name}*"
            ]
        }
    ]
}
POLICY
}

resource "aws_kms_key" "cloudtrail_key" {
  description             = "${var.prefix}-cloudtrail-key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "Key policy created by CloudTrail",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.creds.account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow CloudTrail to encrypt logs",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "kms:GenerateDataKey*",
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${data.aws_caller_identity.creds.account_id}:trail/*"
        }
      }
    },
    {
      "Sid": "Allow CloudTrail to describe key",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "kms:DescribeKey",
      "Resource": "*"
    },
    {
      "Sid": "Allow principals in the account to decrypt log files",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "kms:Decrypt",
        "kms:ReEncryptFrom"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:CallerAccount": "${data.aws_caller_identity.creds.account_id}"
        },
        "StringLike": {
          "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${data.aws_caller_identity.creds.account_id}:trail/*"
        }
      }
    },
    {
      "Sid": "Allow alias creation during setup",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "kms:CreateAlias",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:ViaService": "ec2.${data.aws_region.region.name}.amazonaws.com",
          "kms:CallerAccount": "${data.aws_caller_identity.creds.account_id}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_cloudtrail" "trail_1" {
  depends_on = [
    "aws_iam_role.cloud_watch_logs_role",
    "aws_iam_role_policy.cloud_watch_logs_role_policy",
    "aws_s3_bucket.cloudtrail_bucket",
    "aws_s3_bucket_policy.cloudtrail_bucket_policy",
    "aws_kms_key.cloudtrail_key",
  ]

  name                          = "${var.prefix}-trail-01"
  s3_bucket_name                = "${aws_s3_bucket.cloudtrail_bucket.id}"
  include_global_service_events = true
  enable_logging                = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudwatch_log_group.arn}"
  cloud_watch_logs_role_arn  = "${aws_iam_role.cloud_watch_logs_role.arn}"
  kms_key_id                 = "${aws_kms_key.cloudtrail_key.arn}"
}