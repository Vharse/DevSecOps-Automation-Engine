DevSecOps Automation Engine

An enterprise-grade, centralized DevSecOps Automation Engine designed to standardize security gates across modern CI/CD software delivery pipelines. Built with modular, decoupled reusable workflows, this engine automatically enforces Static Application Security Testing (SAST), Code Quality analysis, independent Secret Scanning, Software Bill of Materials (SBOM) generation, Dynamic Application Security Testing (DAST) with authenticated scan coverage, Infrastructure-as-Code (IaC) policy compliance, OpenSSF supply chain security posture checks, automated dependency updates via Dependabot, centralized vulnerability management in DefectDojo, and real-time SIEM event correlation.

**Architecture Overview**

The DevSecOps Automation Engine functions as a centralized security authority. Client repositories or local pipelines execute modular, parallel reusable workflows to enforce shift-left security before code compilation or deployment.

```
                             ┌───────────────────────────────────────────┐
                             │           Developer Push / PR             │
                             └─────────────────────┬─────────────────────┘
                                                   │
                                                   ▼
                             ┌───────────────────────────────────────────┐
                             │      GitHub Actions Security Workflow     │
                             └─────────────────────┬─────────────────────┘
                                                   │
      ┌────────────┬────────────┬────────────┬─────┴──────┬────────────┬────────────┬────────────┐
      ▼            ▼            ▼            ▼            ▼            ▼            ▼            ▼
┌───────────┐┌───────────┐┌───────────┐┌───────────┐┌───────────┐┌───────────┐┌───────────┐┌───────────┐
│   SAST &  ││  Secret   ││ Container ││   DAST    ││  IaC /    ││  OpenSSF  ││   SIEM    ││  GitHub   │
│  Quality  ││ Scanning  ││ & SBOM    ││  OWASP    ││  OPA /    ││ Scorecard ││ Telemetry ││ Webhook / │
│  Semgrep  ││ Gitleaks  ││  Trivy /  ││ ZAP Auto  ││ Kustomize ││   SARIF   ││ Elastic   ││  Slack    │
│  Sonar    ││           ││   SPDX    ││   Plan    ││  Checkov  ││           ││           ││  Alerts   │
└─────┬─────┘└─────┬─────┘└─────┬─────┘└─────┬─────┘└─────┬─────┘└─────┬─────┘└─────┬─────┘└─────┬─────┘
      └────────────┴────────────┴────────────┴──────┬─────┴────────────┴────────────┴────────────┘
                                                   │
                                                   ▼
                             ┌───────────────────────────────────────────┐
                             │       DefectDojo Vulnerability Mgr        │
                             │   (Centralized Triage & SLA Tracking)     │
                             └─────────────────────┬─────────────────────┘
                                                   │
                                                   ▼
                             ┌───────────────────────────────────────────┐
                             │      Elastic SIEM Telemetry Collector     │
                             │           (devsecops-pipeline-logs)       │
                             └───────────────────────────────────────────┘
```
**Key Accomplishments & Technical Features**

    **Decoupled Reusable Workflow Architecture (security-check.yml)**

1. Modularized monolithic jobs into parallel, independent execution tracks (sast.yml, secret-scanning.yml, container-sca-sbom.yml, dast.yml, iac-opa.yml, scorecard.yml).

2. Dynamically evaluates target branch conditions: enforces strict build-blocking gates (exit-code 1) on main and PRs targeting main, while operating in Advisory Mode (exit-code 0) on feature branches.

    **Decoupled Static Code, Quality & Secret Analysis**

1. Independent Secret Detection (secret-scanning.yml): Runs Gitleaks in parallel with zero dependency on static code analysis, blocking hardcoded API keys, passwords, and private SSH keys with rapid feedback loops.

2. Containerized Semgrep SAST (sast.yml): Executes Semgrep via direct Docker invocation to ensure engine stability and bypass third-party action policy restrictions. Detects SQL injection, XSS, and dangerous code patterns while outputting standard SARIF artifacts.

3. SonarQube Code Quality Gate (sast.yml): Measures technical debt, code coverage, and quality gate compliance across polyglot codebases.

    **Container Security & Software Bill of Materials (SBOM)**

1. Trivy Container Scan: Evaluates built container images (local-test-image:latest) for high/critical vulnerabilities with ignore-unfixed: true enabled to eliminate unpatchable OS vendor noise.

2. SPDX SBOM Generation: Automated creation and artifact upload of standard SPDX SBOM inventories (sbom.spdx.json) for supply chain visibility.

    **Dynamic Application Security Testing (DAST - OWASP ZAP)**

1. Isolated Bridge Networking: Deploys target applications on a dedicated Docker bridge network (zap-net) to eliminate proxy host port collisions during execution.

2. Authenticated Automation Plans: Automated spidering and active vulnerability scanning using OWASP ZAP Automation Framework (.zap/zap-plan.yaml) with form-based authentication support and session persistence checks.

3. Health-Checked Target Bootstrapping: Implements automated target application readiness polling prior to scanner execution to eliminate false-start execution failures.

    **Policy-as-Code Governance & IaC Overlays (iac-opa.yml / OPA / Kustomize)**

1. Kustomize Base & Environment Overlays: Renders Kubernetes manifests from shared base resources (`k8s/base/`) and environment-specific overlays (`k8s/overlays/local` and `k8s/overlays/prod`) into `/tmp/rendered-k8s/` during CI without requiring a live cluster, followed by static Kubernetes security scanning with Checkov (`soft_fail: false`).
2. Custom Open Policy Agent rules (`policies/opa/`) run unit tests (`opa test policies/opa/ -v`), evaluate `data.kubernetes.pod_security.deny` per environment overlay, and evaluate `data.main.deny` against `tfplan.json` when a Terraform plan file is generated from `infra/terraform/`.
3. Enforces strict policy evaluation to block non-compliant configurations prior to deployment.

    **Supply Chain Security, Dependabot & Action Hardening**

1. Automated Dependency Updates (dependabot.yml): Configured Dependabot to actively monitor and automatically open pull requests for GitHub Actions workflows and pip dependencies, ensuring third-party packages stay patched against vulnerabilities.
2. Full Commit SHA Pinning: All third-party GitHub Actions across all workflow steps are pinned directly to immutable 40-character commit SHAs to protect against supply chain tampering.
3. OpenSSF Scorecard: Automatically evaluates repository posture, top-level token permissions, branch protections, and maintenance health, publishing SARIF reports directly to the GitHub Security tab.

    **DefectDojo Centralized Vulnerability Management (defectdojo-ingestion.yml)**

1. Gates execution on the completion of parallel scan jobs (sast, secret-scanning, container-and-sbom, dast, iac-and-opa).
2. Ingests JSON/SARIF artifacts from Gitleaks, Semgrep, Trivy, OWASP ZAP, and OPA directly into DefectDojo.
3. Centralizes vulnerability tracking, deduplication, historical trend analysis, and SLA enforcement across organizational repositories.

    **Elastic SIEM Telemetry & Security Operations (siem-telemetry.yml)**

1. Formats pipeline execution metrics into structured JSON telemetry payloads.
2. Ships security logs into Elasticsearch / Elastic SIEM (devsecops-pipeline-logs-* index) for real-time SOC monitoring.

    **Repository Webhook & Slack Notifications**

1. Repository events are delivered via a configured GitHub repository webhook (`application/json` with a generated GitHub webhook secret) rather than embedding inline Slack notification steps inside workflow YAML.

### Repository Structure
```Plaintext

Devsecops-Automation-Engine/
├── .github/
│   ├── dependabot.yml                        # Automated dependency updates configuration
│   └── workflows/
│       ├── container-sca-sbom.yml            # Container scanning & SBOM workflow
│       ├── dast.yml                          # OWASP ZAP Dynamic Application Security Testing workflow
│       ├── defectdojo-ingestion.yml          # Centralized DefectDojo ingestion gate
│       ├── delete-actions.yml                # Workflow run cleanup automation
│       ├── iac-opa.yml                       # Kustomize, Checkov & OPA IaC policy workflow
│       ├── sast.yml                          # Semgrep SAST & SonarQube code quality workflow
│       ├── scorecard.yml                     # OpenSSF Scorecard posture workflow
│       ├── secret-scanning.yml               # Gitleaks secret detection workflow
│       ├── security-check.yml                # Main execution & orchestration pipeline
│       └── siem-telemetry.yml                # Elastic SIEM logging workflow
├── .zap/
│   └── zap-plan.yaml                         # OWASP ZAP Automation Framework configuration
├── infra/
│   └── terraform/
│       ├── environments/                     # Terraform environment configurations
│       └── modules/                          # Reusable Terraform modules
├── k8s/
│   ├── base/
│   │   ├── deployment.yaml                   # Base Kubernetes deployment manifest
│   │   ├── kustomization.yaml                # Base Kustomize configuration
│   │   ├── namespace.yaml                    # Base namespace manifest
│   │   └── networkpolicy.yaml                # Base network policy manifest
│   └── overlays/
│       ├── local/                            # Local/dev Kustomize overlay
│       └── prod/                             # Production Kustomize overlay
├── policies/
│   └── opa/
│       ├── kubernetes-pod-security.rego      # Kubernetes pod security Rego policies
│       ├── kubernetes-pod-security_test.rego # OPA unit tests for Kubernetes policies
│       └── s3_check.rego                     # Terraform / S3 OPA Rego compliance policies
├── src/
│   ├── Dockerfile                            # Container definition
│   ├── app.py                                # Application source entrypoint
│   └── requirements.txt                      # Python application dependencies
├── LICENSE                                   # MIT Open Source License
├── README.md                                 # System documentation
└── SECURITY.md                               # Vulnerability disclosure and security policy
```
## Required Repository Secrets

To run all pipeline jobs successfully, configure these secrets under Settings → Secrets and variables → Actions

```
#Secret Name   			    Description   					 		                            Example / Scope
SEMGREP_APP_TOKEN    	  (Optional) Authentication token from Semgrep AppSec    	semgrep_...
SONAR_TOKEN    			    Global analysis authentication token for SonarQube    	sqa_...
SONAR_HOST_URL    		  Endpoint URL for SonarQube server    				            https://sonar.your-domain.com
APP_USER    			      Test user credential for DAST authentication scans    	dast_scanner
APP_PASSWORD    		    Test user password for DAST authentication scans    		324sA0Exxxxxxxxx
DEFECTDOJO_URL    		  Endpoint URL for DefectDojo instance    			          https://defectdojo.your-domain.com
DEFECTDOJO_API_KEY    	User API Key for DefectDojo ingestion    			          Token 8a9b...
ELASTIC_HOST    		    Endpoint URL for Elastic SIEM cluster    			          https://elastic.your-domain.com:9243
ELASTIC_API_KEY    		  Base64 encoded Elastic API Key for log ingestion    		V2...==
SLACK_WEBHOOK_URL    		(Optional) Slack Webhook URL for channel alarting       https://hooks.slack.com/services........

```
## Usage & Integration
Reusing this Engine in Client Repositories:

To consume this centralized security engine inside any client repository, create `.github/workflows/security-check.yml` in the client repo and point uses: from `uses:./.github/workflows/security-check.yml` to `uses:Vharse/Devsecops-Automation-Engine/.github/workflows/security-check.yml@main`

```
name: Security Check

on:
  push:
    branches: [ "main", "your-github-branch-name" ]
  pull_request:
    branches: [ "main", "your-github-branch-name" ]

jobs:
  run-security-engine:
    uses: Vharse/Devsecops-Automation-Engine/.github/workflows/security-check.yml@main
    permissions:
      contents: read
      security-events: write
      id-token: write
      checks: write
      actions: read
    secrets: inherit

