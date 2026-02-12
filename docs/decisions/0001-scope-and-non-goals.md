# 0001 – Scope and Non-Goals

## Goal
Build a minimal ingestion spine for tachograph files:
S3 (raw storage) → Lambda (ingest handler) → DynamoDB (ingestion ledger).

## Definition of Done (Phase 1)
- Private S3 bucket for raw uploads.
- Lambda triggered on object creation.
- Lambda writes metadata record to DynamoDB.
- CloudWatch logging enabled with sensible retention.
- Deployable via Terraform.

## Non-Goals (Phase 1)
- Authentication or user management.
- Compliance or tachograph analysis logic.
- Third-party DDD compatibility fixes.
- Multi-tenancy.
- UI or reporting layer.
- Cost optimisation refinements beyond basics.

## Environment Strategy
Single environment: dev.

## Deployment Strategy
Manual Terraform apply initially.
CI/CD added after base infrastructure is stable.
