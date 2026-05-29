# OCI K3s Investigation Postmortem
Date: 2026-05-29

## Objective

Deploy a lightweight Kubernetes cluster on Oracle Cloud Infrastructure (OCI)
to support the BizRanker Command Center platform.

Intended workloads:

- ArgoCD
- Grafana
- Prometheus
- GitOps workflows
- Future BizRanker services

---

## Environment

Cloud Provider:
- Oracle Cloud Infrastructure (OCI)

Region:
- us-sanjose-1

Operating System:
- Ubuntu 20.04

Kubernetes Distribution:
- K3s

Networking:
- Flannel

Nodes:
- bizranker-k3s-master-01
- bizranker-k3s-worker-01

---

## Symptoms

Cluster components repeatedly failed.

Observed:

- CoreDNS never became healthy
- Metrics Server CrashLoopBackOff
- Local Path Provisioner CrashLoopBackOff
- Traefik installer CrashLoopBackOff
- Traefik CRD installer CrashLoopBackOff

Diagnostic testing showed:

- Kubernetes API reachable locally on 127.0.0.1:6443
- Service IP 10.43.0.1 unreachable from pods
- CoreDNS service 10.43.0.10 had no endpoints
- kube-system components unable to stabilize

---

## Investigation Performed

Verified:

- OCI routing
- Flannel configuration
- iptables rules
- NAT rules
- Kubernetes service definitions
- Pod networking
- Bridge networking
- br_netfilter module
- sysctl bridge settings
- Service CIDR routing
- Host firewall rules

Additional tests included:

- Manual FORWARD chain rules
- Manual DNAT rules
- Pod-to-service connectivity tests
- Rebuild attempts
- Reinstallation attempts
- Alternative Traefik investigations

---

## Findings

The exact root cause was not conclusively identified.

Strong indicators suggest:

- OCI networking interaction
- OCI free-tier limitations
- OCI/K3s edge-case behavior
- Flannel/service routing interaction

The Kubernetes API itself was functional.

The failure appeared to occur inside the cluster service-routing layer.

---

## Strategic Decision

The project objective is:

Build Command Center.

The project objective is NOT:

Spend unlimited time debugging OCI networking.

Therefore:

- OCI remains the primary BizRanker infrastructure provider.
- Existing OCI resources remain intact.
- Kubernetes lab work may be moved to GCP free tier.
- Command Center delivery takes priority over OCI K3s perfection.

---

## Lessons Learned

A working architecture is more valuable than a perfect architecture.

Customers hire engineers who can solve business problems.

The ability to adapt infrastructure strategy is often more valuable than
winning every technical battle.

Resourcefulness beats stubbornness.

If we can escape from Alcatraz, we can solve customer problems.

---

## Future Revisit Checklist

If OCI Kubernetes is revisited:

- Rebuild using Oracle Linux 9
- Test K3s again
- Evaluate MicroK8s
- Evaluate k0s
- Compare against GCP cluster behavior
- Document packet flow between pod network and service network
- Capture tcpdump traces during service-IP access

Status:
DEFERRED

Reason:
Command Center delivery takes priority.
