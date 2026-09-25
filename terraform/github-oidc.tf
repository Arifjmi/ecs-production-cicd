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


    condition {

      test = "StringEquals"

      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }


    condition {

      test = "StringLike"

      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"
      ]
    }
  }
}
resource "aws_iam_role" "github_actions" {

  name = "${local.name}-github-actions"

  assume_role_policy = data.aws_iam_policy_document.github_assume.json
}
data "aws_iam_policy_document" "github_deploy" {

  statement {

    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = [
      "*"
    ]
  }


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


resource "aws_iam_role_policy" "github_deploy" {

  name = "${local.name}-github-deploy"

  role = aws_iam_role.github_actions.id

  policy = data.aws_iam_policy_document.github_deploy.json
}

