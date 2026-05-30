# BizRanker Engineering Journal

## Purpose

This document serves as the living engineering history of the BizRanker platform.

It records major architectural decisions, incidents, pivots, lessons learned, platform evolution, and strategic direction.

Unlike a résumé, this document captures what was actually built, why decisions were made, what obstacles were encountered, and how they were overcome.

---

# Origins

## FloridaSOS

The roots of BizRanker began with FloridaSOS.

FloridaSOS was conceived as a proof-of-concept platform for identifying and tracking aged business entities from public Secretary of State records.

The original platform focused on:

* Florida LLCs
* Daily scraping
* Database ingestion
* Search and export capabilities
* Login-protected access

The concept originated from observing opportunities discussed within the business credit and real estate investing communities.

The initial objective was to locate potentially valuable aged entities and create a repeatable discovery process.

FloridaSOS demonstrated that large-scale public business entity collection was technically achievable.

---

# Evolution Into BizRanker

FloridaSOS eventually evolved into the broader BizRanker vision.

The platform expanded from simple discovery toward:

* Entity ranking
* Credit enrichment
* Funding readiness analysis
* Business intelligence
* Investor tooling
* Corporate acquisition workflows

The long-term vision became:

A nationwide platform capable of identifying, scoring, ranking, and packaging business entities based on age, credibility, creditworthiness, and funding potential.

---

# Core Platform Vision

The target BizRanker workflow is:

Secretary of State Data
↓
Scraping
↓
Normalization
↓
Scoring
↓
Ranking
↓
Marketplace
↓
Funding Services
↓
Asset Protection Services

Future enrichment sources include:

* Dun & Bradstreet
* Experian Business
* Equifax Business
* Banking data
* Funding partners

The long-term goal is nationwide coverage.

Current state:

* Florida LLCs

Target state:

* All entity types
* All U.S. states
* Eventual international expansion

---

# Architectural Philosophy

BizRanker was designed around several principles:

## Continuous Collection

Scraping should never stop.

Data freshness is a competitive advantage.

Entity records should be continuously refreshed and re-evaluated.

---

## Recovery First

Every system should be recoverable.

This philosophy eventually led to:

* realm-primer
* passdown documents
* continuity kits
* engineering journals
* infrastructure documentation

The goal is to prevent loss of momentum regardless of:

* cloud failures
* laptop failures
* chat session failures
* personnel changes

---

## Build While Learning

The platform intentionally evolved in public.

Rather than waiting for a perfect design, working systems were built and improved continuously.

This accelerated learning and exposed real-world constraints earlier.

---

# OCI Era

The first major cloud environment was Oracle Cloud Infrastructure.

OCI provided substantial free-tier resources and enabled:

* command-center
* api-01
* db-01
* web infrastructure
* K3s experimentation

Several environments were successfully launched.

---

## OCI Challenges

Over time, multiple limitations emerged:

* quota restrictions
* boot volume limitations
* free-tier inconsistencies
* resource allocation uncertainty

Expansion efforts eventually encountered hard infrastructure limits.

Repeated attempts were made to preserve and expand the cluster.

Significant effort was invested investigating:

* Terraform state
* instance quotas
* boot volume quotas
* detached volume recovery strategies

---

# The Great GCP Pivot

Rather than allowing infrastructure limitations to halt progress, the platform pivoted.

Google Cloud Platform was selected as the new Kubernetes home.

Reasons included:

* mature Kubernetes ecosystem
* GKE Autopilot
* stronger operational tooling
* available trial credits

Within hours of gaining access:

* GKE was provisioned
* cluster access established
* ArgoCD deployed
* GitOps workflows restored

This became one of the fastest major infrastructure pivots in the project's history.

---

# ArgoCD Incident

A significant issue occurred immediately after deployment.

Several ArgoCD components remained Pending indefinitely.

Initial symptoms suggested:

* GCP quota issues
* autoscaler failures
* cluster provisioning defects

Investigation revealed the actual problem:

ArgoCD's default resource requests were dramatically oversized relative to actual usage.

Examples included workloads requesting multiple gigabytes of RAM while consuming only a few megabytes.

After tuning resource requests:

* ArgoCD Server recovered
* Repo Server recovered
* Dex recovered
* Application Controller recovered
* Notifications recovered
* Redis recovered

The incident reinforced a critical lesson:

Kubernetes schedules requests, not actual usage.

---

# UI Acceleration Period

Parallel to infrastructure work, rapid UI development occurred.

Major milestones included:

* Investor Prototype
* Corey Demonstration Environment
* Entrepreneurs League Concepts
* Desktop Experience
* Mobile Experience

Development velocity increased significantly through iterative collaboration and continuous deployment.

The project demonstrated that modern React-based frontends could be rapidly refined when architecture, deployment, and feedback loops were tightly integrated.

---

# Command Center

The Command Center initiative represents the operational heart of BizRanker.

Planned components include:

* Kubernetes
* ArgoCD
* Rancher
* Prometheus
* Grafana
* SigNoz
* GitOps workflows
* Infrastructure monitoring
* Automated remediation

The objective is a professional-grade operational platform capable of supporting future BizRanker growth.

---

# Future Objectives

## Data Expansion

Expand beyond Florida.

Targets include:

* All entity types
* Additional states
* Nationwide collection

---

## Credit Enrichment

Replace simulated scoring with real integrations.

Research includes:

* API structures
* field mappings
* field lengths
* normalization requirements
* bureau-specific schemas

Potential providers:

* Dun & Bradstreet
* Experian Business
* Equifax Business

---

## Funding Ecosystem

Future workflows may include:

* funding readiness
* lender matching
* acquisition support
* white-glove onboarding

---

## Long-Term Goal

BizRanker is not intended as a quick acquisition target.

The objective is to build a durable platform that generates real value, real revenue, and real operational capability.

The project is intended to mature into the closest practical implementation of the original vision possible.

The journey continues.


---

# Command Center Milestone: GKE + ArgoCD Operational

## Summary

The BizRanker Command Center is now operational on Google Kubernetes Engine.

After OCI resource limitations slowed Kubernetes expansion, the platform pivoted quickly to GCP. Within one development cycle, GKE Autopilot was provisioned, kubectl access was configured, ArgoCD was installed, debugged, tuned, and brought fully online.

## Current Operational Stack

- Google Kubernetes Engine Autopilot
- ArgoCD
- GitHub-backed infrastructure repository
- kubectl-based operational access
- GKE managed monitoring components
- Resource-tuned ArgoCD control plane

## Technical Value Demonstrated

This milestone demonstrates:

- Cloud migration judgment
- Kubernetes troubleshooting
- ArgoCD installation and recovery
- GKE Autopilot scheduling analysis
- Resource request tuning
- GitOps platform readiness
- Incident documentation discipline

## Interview and Investor Relevance

This environment is not theoretical.

It demonstrates real-world platform engineering under constraint:

- OCI quota issues were investigated.
- GCP was selected as the faster path forward.
- ArgoCD deployment issues were root-caused.
- Kubernetes scheduler behavior was analyzed.
- Resource requests were corrected.
- The full ArgoCD stack was brought online.

This platform now serves as both operational infrastructure and portfolio evidence.


---

# Portfolio Entry - 2026-05-30 14:35:09 PDT

## Pipeline Test

Verified the BizRanker Engineering Journal append pipeline from the local repository.

This confirms that portfolio entries can be drafted quickly, appended to the living engineering journal, committed, and pushed to GitHub.

