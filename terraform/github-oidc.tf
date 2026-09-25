# ============================================================
# GitHub Actions OIDC Provider
# ============================================================

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.github.certificates[0].sha1_fingerprint
  ]
}


# ============================================================
# GitHub Actions OIDC Trust Policy
# ============================================================

data "aws_iam_policy_document" "github_assume" {

  statement {

    effect = "Allow"

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    # GitHub OIDC audience
    condition {

      test = "StringEquals"

      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    # GitHub immutable OIDC subject
    #
    # Repository:
    # Arifjmi/ecs-production-cicd
    #
    # Owner ID:
    # 148271832
    #
    # Repository ID:
    # 1387248610
    #
    # Branch:
    # main

    condition {

      test = "StringEquals"

      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:Arifjmi@148271832/ecs-production-cicd@1387248610:ref:refs/heads/main"
      ]
    }
  }
}


# ============================================================
# GitHub Actions IAM Role
# ============================================================

resource "aws_iam_role" "github_actions" {

  name = "${local.name}-github-actions"

  assume_role_policy = data.aws_iam_policy_document.github_assume.json
}


# ============================================================
# GitHub Actions Deployment Permissions
# ============================================================

data "aws_iam_policy_document" "github_deploy" {

  # ----------------------------------------------------------
  # ECR Authentication
  # ----------------------------------------------------------

  statement {

    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = [
      "*"
    ]
  }


  # ----------------------------------------------------------
  # Push Docker Image to ECR
  # ----------------------------------------------------------

  statement {

    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    resources = [
      aws_ecr_repository.app.arn
    ]
  }


  # ----------------------------------------------------------
  # ECS Deployment
  # ----------------------------------------------------------

  statement {

    effect = "Allow"

    actions = [
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeServices",
      "ecs:UpdateService"
    ]

    resources = [
      "*"
    ]
  }


  # ----------------------------------------------------------
  # Pass ECS Task Execution Role
  # ----------------------------------------------------------

  statement {

    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      aws_iam_role.ecs_task_execution.arn
    ]
  }
}


# ============================================================
# Attach Deployment Policy to GitHub Actions Role
# ============================================================

resource "aws_iam_role_policy" "github_deploy" {

  name = "${local.name}-github-deploy"

  role = aws_iam_role.github_actions.id

  policy = data.aws_iam_policy_document.github_deploy.json
}
