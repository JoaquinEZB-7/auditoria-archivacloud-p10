# =============================================================================
# ArchivaCloud — Infraestructura como Código (Terraform)
# Arquitectura objetivo endurecida. Corrige los hallazgos de la auditoría.
# Hallazgos remediados: VULN-008 (versioning), VULN-009 (logging),
# VULN-010 (cifrado KMS/CMK), VULN-011 (TLS forzado), VULN-012 (IAM mínimo
# privilegio) y refuerzo de Block Public Access.
# =============================================================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  description = "Región AWS del bucket"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Nombre del bucket de documentos"
  type        = string
  default     = "archivacloud-p10-jz"
}

# -----------------------------------------------------------------------------
# VULN-010 — Clave gestionada por el cliente (CMK) para cifrado SSE-KMS
# -----------------------------------------------------------------------------
resource "aws_kms_key" "archiva" {
  description             = "CMK para cifrado del bucket ArchivaCloud"
  deletion_window_in_days = 30
  enable_key_rotation     = true # rotación automática anual
}

resource "aws_kms_alias" "archiva" {
  name          = "alias/archivacloud-cmk"
  target_key_id = aws_kms_key.archiva.key_id
}

# -----------------------------------------------------------------------------
# Bucket de logs de acceso (destino del server access logging)
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "logs" {
  bucket = "${var.bucket_name}-logs"
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------------------
# Bucket principal de documentos
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "archiva" {
  bucket = var.bucket_name
}

# VULN-008 — Versioning habilitado (recuperación ante sobrescritura/borrado)
resource "aws_s3_bucket_versioning" "archiva" {
  bucket = aws_s3_bucket.archiva.id
  versioning_configuration {
    status = "Enabled"
  }
}

# VULN-010 — Cifrado por defecto con SSE-KMS (CMK) + Bucket Key
resource "aws_s3_bucket_server_side_encryption_configuration" "archiva" {
  bucket = aws_s3_bucket.archiva.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.archiva.arn
    }
    bucket_key_enabled = true
  }
}

# Refuerzo — Block Public Access en los cuatro flags
resource "aws_s3_bucket_public_access_block" "archiva" {
  bucket                  = aws_s3_bucket.archiva.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# VULN-009 — Server access logging hacia el bucket de logs
resource "aws_s3_bucket_logging" "archiva" {
  bucket        = aws_s3_bucket.archiva.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "access-logs/"
}

# Gestión de retención (limpieza de versiones y subidas incompletas)
resource "aws_s3_bucket_lifecycle_configuration" "archiva" {
  bucket = aws_s3_bucket.archiva.id
  rule {
    id     = "retencion-versiones"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# VULN-011 — Política de bucket que DENIEGA conexiones sin TLS
resource "aws_s3_bucket_policy" "archiva" {
  bucket = aws_s3_bucket.archiva.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.archiva.arn,
          "${aws_s3_bucket.archiva.arn}/*"
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# VULN-012 — Rol IAM de la aplicación con política de MÍNIMO PRIVILEGIO
# (sustituye las credenciales en .env por un rol asumido por el cómputo)
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "archiva_app" {
  name               = "archivacloud-app-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_policy_document" "s3_min" {
  statement {
    sid     = "S3MinimoPrivilegio"
    actions = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket"]
    resources = [
      aws_s3_bucket.archiva.arn,
      "${aws_s3_bucket.archiva.arn}/*"
    ]
  }
  statement {
    sid       = "UsoDeLaCMK"
    actions   = ["kms:Encrypt", "kms:Decrypt", "kms:GenerateDataKey"]
    resources = [aws_kms_key.archiva.arn]
  }
}

resource "aws_iam_role_policy" "archiva_app" {
  name   = "archivacloud-s3-min"
  role   = aws_iam_role.archiva_app.id
  policy = data.aws_iam_policy_document.s3_min.json
}

output "bucket_arn" {
  value = aws_s3_bucket.archiva.arn
}

output "kms_key_arn" {
  value = aws_kms_key.archiva.arn
}

output "app_role_arn" {
  value = aws_iam_role.archiva_app.arn
}
