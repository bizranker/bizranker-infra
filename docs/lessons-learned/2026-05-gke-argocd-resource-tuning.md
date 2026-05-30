# GKE Autopilot + ArgoCD Resource Planning Lessons Learned

## Date

May 2026

## Summary

During the migration of the BizRanker Command Center from Oracle Cloud Infrastructure (OCI) to Google Kubernetes Engine (GKE) Autopilot, ArgoCD appeared to be malfunctioning because several core components remained in a Pending state for an extended period.

Initial troubleshooting focused on GKE quotas, cluster autoscaling, node provisioning, and Autopilot limitations. Event logs showed repeated messages such as:

* Insufficient CPU
* Insufficient Memory
* FailedScaleUp
* GCE quota exceeded

This initially suggested a cloud-provider quota problem.

## Root Cause

The underlying issue was not actual resource exhaustion but excessive Kubernetes resource requests defined by the default ArgoCD deployment manifests.

Several ArgoCD components requested approximately 2 GiB of memory each despite consuming only a fraction of that amount at runtime.

Examples observed:

| Component                        | Requested Memory | Actual Usage |
| -------------------------------- | ---------------- | ------------ |
| argocd-redis                     | 2 GiB            | ~6 MiB       |
| argocd-notifications-controller  | 2 GiB            | ~20 MiB      |
| argocd-applicationset-controller | 2 GiB            | ~33 MiB      |

Because Kubernetes schedules based on requested resources rather than actual utilization, the scheduler believed the cluster was effectively full.

As a result:

* argocd-server initially remained Pending
* argocd-repo-server remained Pending
* argocd-dex-server remained Pending
* argocd-application-controller remained Pending
* Cluster autoscaler repeatedly attempted scale-ups
* Scale-up operations entered backoff conditions
* Misleading quota-related messages complicated diagnosis

## Resolution

Resource requests were manually reduced to values appropriate for a proof-of-concept environment.

Typical adjustments included:

* CPU: 100m
* Memory: 128 MiB - 256 MiB

Redis was reduced even further:

* CPU: 50m
* Memory: 64 MiB

After patching the deployments and restarting the affected workloads:

* argocd-server became healthy
* argocd-repo-server became healthy
* argocd-dex-server became healthy
* argocd-notifications-controller became healthy
* argocd-applicationset-controller became healthy
* argocd-application-controller became healthy

The entire ArgoCD stack successfully entered a Running state.

## Key Lessons

### 1. Kubernetes Schedules Requests, Not Usage

Actual memory utilization may be low while requested resources are high.

Always inspect:

```bash
kubectl top pods -A
kubectl describe node <node>
```

before assuming a cluster is out of capacity.

### 2. Default Helm Values Are Not Sacred

Many projects ship with enterprise-oriented defaults intended for large production environments.

Review resource requests before deployment, especially in:

* Homelabs
* Free-tier environments
* Proof-of-concept clusters
* Training environments

### 3. Pending Pods Require Event Analysis

The most valuable command during this incident was:

```bash
kubectl describe pod <pod>
```

Specifically the Events section.

Events revealed:

* FailedScheduling
* Insufficient Memory
* Scale-up attempts
* Autoscaler backoff conditions

which ultimately led to the correct diagnosis.

### 4. GKE Was Not The Problem

The cluster itself functioned correctly.

GKE Autopilot:

* Provisioned nodes successfully
* Scheduled workloads correctly
* Attempted automatic scaling
* Reported resource constraints accurately

The issue originated from unrealistic workload requests rather than a cloud-provider failure.

## Outcome

The BizRanker Command Center successfully migrated to GKE.

ArgoCD is fully operational.

The investigation provided valuable insight into:

* Kubernetes scheduling behavior
* Resource requests vs actual usage
* Autoscaler decision-making
* Capacity planning in constrained environments

Future deployments should include a review of all resource requests before assuming infrastructure limitations.

