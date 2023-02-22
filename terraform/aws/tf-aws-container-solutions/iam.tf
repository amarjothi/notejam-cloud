// IAM Role for ECS Task Role
resource "aws_iam_role" "ecs_task_role" {
  name = "notejampoc-ecs-task-role-${var.env}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

// IAM Policy for ECS Task Role to allow access to CLoudwatch Logs
resource "aws_iam_policy" "ecs_task_role_policy" {
  #checkov:skip=CKV_AWS_290: "Allow access to Cloudwatch Logs"
  name = "notejampoc-ecs-task-role-policy-${var.env}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:*"
      ],
      "Resource": [ "*" ],
      "Effect": "Allow"
    }
  ]
}
EOF
}

// Attach the policy to the role
resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_role_policy.arn
}

// Attach the policy to the role
resource "aws_iam_role_policy_attachment" "ecs_task_role_secrets_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.secrets_manager.arn
}

// IAM role for ECS task execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role-${var.env}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

// Define IAM policy to allow access to ECR
resource "aws_iam_policy" "ecr" {
#checkov:skip=CKV_AWS_290: Open for the time being but can lock down to account registry
#checkov:skip=CKV_AWS_289: "Open for timebeing will lock down" 
  name        = "ecr-policy-${var.env}"
    description = "Allow access to ECR"
    policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
{
"Sid": "AllowPull",
"Effect": "Allow",
"Action": [
"ecr:*"
],
"Resource": [
"*"
]
}
]
}
EOF
}

//Define Iam policy to allow access to AWS secrets manager to get get secret value
resource "aws_iam_policy" "secrets_manager" {
  name        = "secretsmanager-policy-${var.env}"
    description = "Allow access to secrets manager"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ],
      "Resource": [
        "arn:aws:secretsmanager:eu-west-2:${data.aws_caller_identity.current.account_id}:secret:*"
      ]
    }
  ]
}
EOF
}

//Attach secretsmanager policy to IAM Role
resource "aws_iam_role_policy_attachment" "secrets_manager" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.secrets_manager.arn
}

//Attach logs policy to IAM Role
resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_role_policy.arn
}

// Attach policy to IAM role
resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecr.arn
}
