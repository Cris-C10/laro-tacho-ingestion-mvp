\# LARO Tacho Ingestion MVP



\## Overview



This project is part of a larger compliance platform focused on tachograph (.ddd) data processing.



The long-term goal is to:



\- Extract raw `.ddd` files directly from driver smart cards (Rust-based extractor)

\- Parse and interpret tachograph data

\- Ingest files into a secure cloud backbone

\- Analyse driving/rest patterns against EU compliance rules

\- Return plain-text infringement summaries and required rest calculations

\- Deliver results across desktop, mobile, and edge/IoT devices



This repository represents the event-driven cloud ingestion backbone that connects raw file uploads to structured processing.





\## Architecture Overview

```

+----------------------+
|                      |
|    Driver Smartcard  | 
|                      |
+--------+-------------+
         |
         |
         |
         v
+----------------------+
|                      |
|    Rust Extractor    |
|                      |
|    (.ddd generator)  |
|                      |
|    [In Development]  |
|                      |
+--------+-------------+
         |
         |
         | 
         v
+----------------------+
|                      |
|   S3 Raw Bucket      |
|                      |
| (Secure + Versioned) | 
|                      |
|   [Implemented]      |
|                      |
+---------+------------+
          |
          |
          |
  Object Created Event
          |
          |
          |
          v
+----------------------+
|                      |
|   Lambda Ingest      |
|                      |
|   [Implemented]      |
|                      |
+----------+-----------+
           |
           |
           |
           v
+----------------------+
|                      |
| DynamoDB Ledger      |
|                      |
| (Ingestion Tracking) |
|                      |
| [Implemented]        |
|                      |
+----------+-----------+
           |
           |
           | 
           v
+----------------------+
|                      |
| Parser +             |
|                      |
| Compliance Engine    |
|                      |
| [Planned]            |
|                      |
+----------+-----------+
           |
           |
           |
           v
+----------------------+
|                      |
| Plain-Text Results   |
|                      |
| Desktop / Mobile /   |
|                      |
| IoT Integration      |
|                      |
| [Planned]            |
|                      |
+----------------------+

```



\## CURRENT PHASE – Event-Driven Ingestion Backbone



Implemented using Terraform and AWS.



\### Infrastructure Components



\- \*\*S3 Raw Bucket\*\*

&nbsp; - Versioning enabled

&nbsp; - Server-side encryption (AES256)

&nbsp; - Public access fully blocked

&nbsp; - Lifecycle policy: transition to Glacier after 90 days

&nbsp; - Noncurrent versions also transitioned to Glacier



\- \*\*AWS Lambda (Ingest Function)\*\*

&nbsp; - Triggered automatically on S3 object creation

&nbsp; - Prepares ingestion flow

&nbsp; - Designed for future parsing integration



\- \*\*DynamoDB Ingestion Ledger\*\*

&nbsp; - Tracks file ingestion metadata

&nbsp; - Enables idempotency and auditability



\- \*\*IAM Roles and Policies\*\*

&nbsp; - Least-privilege access

&nbsp; - Explicit S3 → Lambda invocation permissions



\- \*\*Modular Terraform Structure\*\*

&nbsp; - `raw\_store`

&nbsp; - `ingestion\_ledger`

&nbsp; - `ingest\_lambda`

&nbsp; - Environment-based deployment (`envs/dev`)



Deployment:



```bash

terraform init

terraform apply





\## Next Phases (Planned \& In development) 



.ddd file parser (Rust)



EU compliance rule engine



Infringement detection logic



Plain-text compliance summaries



API layer for application integration



Desktop and mobile client connectivity



Edge-device ingestion (IoT form factor)









