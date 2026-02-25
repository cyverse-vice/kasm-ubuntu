# HIPAA Clean Room -- Kubernetes Deployment Recommendations

This document provides Kubernetes configuration recommendations for deploying the `swcacti` HIPAA Clean Room KASM desktop container in a production environment.

## 1. Pod Security Context

Run as non-root with all capabilities dropped and privilege escalation blocked.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cleanroom-session
  namespace: hipaa-cleanroom
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: kasm-desktop
      image: harbor.cyverse.org/vice/kasm/ubuntu:swcacti
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: false
        capabilities:
          drop:
            - ALL
      ports:
        - containerPort: 6901
          name: vnc
          protocol: TCP
      env:
        - name: VNC_PW
          valueFrom:
            secretKeyRef:
              name: cleanroom-vnc
              key: password
      resources:
        requests:
          cpu: "2"
          memory: "4Gi"
        limits:
          cpu: "4"
          memory: "8Gi"
          ephemeral-storage: "10Gi"
```

## 2. Network Policies

Deny all egress by default, then whitelist only DNS and CyVerse iRODS.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: cleanroom-deny-all-egress
  namespace: hipaa-cleanroom
spec:
  podSelector:
    matchLabels:
      app: cleanroom
  policyTypes:
    - Egress
  egress: []
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: cleanroom-allow-dns
  namespace: hipaa-cleanroom
spec:
  podSelector:
    matchLabels:
      app: cleanroom
  policyTypes:
    - Egress
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
          podSelector:
            matchLabels:
              k8s-app: kube-dns
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: cleanroom-allow-irods
  namespace: hipaa-cleanroom
spec:
  podSelector:
    matchLabels:
      app: cleanroom
  policyTypes:
    - Egress
  egress:
    - to:
        - ipBlock:
            cidr: 128.196.65.216/32  # data.cyverse.org
      ports:
        - protocol: TCP
          port: 1247
```

> **Note:** Resolve `data.cyverse.org` to its current IP and update the CIDR. Use a DNS-aware network policy engine (e.g., Cilium) for hostname-based rules if available.

## 3. PVC Configuration

Mount sensitive data read-only. Provide a separate writable volume for analysis outputs.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cleanroom-input
  namespace: hipaa-cleanroom
spec:
  accessModes:
    - ReadOnlyMany
  resources:
    requests:
      storage: 50Gi
  storageClassName: encrypted-csi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cleanroom-output
  namespace: hipaa-cleanroom
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
  storageClassName: encrypted-csi
```

Mount them in the pod spec:

```yaml
      volumeMounts:
        - name: input-data
          mountPath: /home/kasm-user/data-store/input
          readOnly: true
        - name: output-data
          mountPath: /home/kasm-user/data-store/output
  volumes:
    - name: input-data
      persistentVolumeClaim:
        claimName: cleanroom-input
        readOnly: true
    - name: output-data
      persistentVolumeClaim:
        claimName: cleanroom-output
```

Use an encrypted `StorageClass` (`encrypted-csi`) backed by encryption-at-rest (e.g., AWS EBS with KMS, or Ceph with LUKS).

## 4. RBAC

Deny interactive access (`exec`, `attach`, `port-forward`) for user service accounts in the cleanroom namespace.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: cleanroom-user
  namespace: hipaa-cleanroom
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["pods/log"]
    verbs: ["get"]
  # Explicitly NO pods/exec, pods/attach, pods/portforward
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: cleanroom-user-binding
  namespace: hipaa-cleanroom
subjects:
  - kind: Group
    name: cleanroom-researchers
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: cleanroom-user
  apiGroup: rbac.authorization.k8s.io
```

## 5. Session Timeout Reaper

CronJob to terminate pods that exceed the 8-hour maximum session.

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cleanroom-reaper
  namespace: hipaa-cleanroom
spec:
  schedule: "*/15 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: cleanroom-reaper
          containers:
            - name: reaper
              image: bitnami/kubectl:latest
              command:
                - /bin/sh
                - -c
                - |
                  MAX_AGE=28800  # 8 hours in seconds
                  NOW=$(date +%s)
                  kubectl get pods -n hipaa-cleanroom -l app=cleanroom -o json | \
                    jq -r '.items[] | select(.status.phase=="Running") |
                      .metadata.name + " " + .status.startTime' | \
                  while read POD START; do
                    START_EPOCH=$(date -d "$START" +%s)
                    AGE=$((NOW - START_EPOCH))
                    if [ "$AGE" -gt "$MAX_AGE" ]; then
                      echo "Terminating $POD (age: ${AGE}s)"
                      kubectl delete pod -n hipaa-cleanroom "$POD" --grace-period=30
                    fi
                  done
          restartPolicy: OnFailure
```

## 6. Audit Logging

Configure a Kubernetes audit policy to log exec/attach/secret access in the cleanroom namespace.

```yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  - level: RequestResponse
    namespaces: ["hipaa-cleanroom"]
    resources:
      - group: ""
        resources: ["pods/exec", "pods/attach", "pods/portforward"]
    verbs: ["create"]
  - level: Metadata
    namespaces: ["hipaa-cleanroom"]
    resources:
      - group: ""
        resources: ["secrets"]
    verbs: ["get", "list", "watch"]
  - level: Metadata
    namespaces: ["hipaa-cleanroom"]
    resources:
      - group: ""
        resources: ["pods"]
    verbs: ["delete"]
```

Ship container logs to a centralized logging stack (e.g., Fluentd/Fluent Bit to Elasticsearch or Loki) for retention and audit review.

## 7. Node Isolation

Use taints and tolerations to schedule clean room pods on dedicated HIPAA-compliant nodes.

```yaml
# On dedicated nodes:
# kubectl taint nodes <node> hipaa=cleanroom:NoSchedule
# kubectl label nodes <node> compliance=hipaa

# In pod spec:
spec:
  nodeSelector:
    compliance: hipaa
  tolerations:
    - key: "hipaa"
      operator: "Equal"
      value: "cleanroom"
      effect: "NoSchedule"
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
              - key: app
                operator: NotIn
                values:
                  - cleanroom
          topologyKey: kubernetes.io/hostname
```

This ensures clean room pods only land on dedicated nodes and no two sessions share the same node.

## 8. Image Signing and Scanning

- **Build-time:** Sign images with [Cosign](https://github.com/sigstore/cosign) in CI after push to Harbor
- **Admission control:** Deploy [Kyverno](https://kyverno.io/) or [Connaisseur](https://github.com/sse-secure-systems/connaisseur) to reject unsigned images in the `hipaa-cleanroom` namespace
- **Vulnerability scanning:** Enable Harbor's built-in Trivy scanner with a policy to block images with Critical/High CVEs

```yaml
# Example Kyverno policy
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: verify-cleanroom-images
spec:
  validationFailureAction: Enforce
  rules:
    - name: verify-signature
      match:
        resources:
          namespaces: ["hipaa-cleanroom"]
          kinds: ["Pod"]
      verifyImages:
        - imageReferences:
            - "harbor.cyverse.org/vice/kasm/ubuntu:swcacti*"
          attestors:
            - entries:
                - keys:
                    publicKeys: |-
                      -----BEGIN PUBLIC KEY-----
                      <your cosign public key here>
                      -----END PUBLIC KEY-----
```

## 9. Backup and Disaster Recovery

- Use [Velero](https://velero.io/) for PVC snapshots on a schedule aligned with session windows
- Configure encrypted backup storage (S3 with SSE-KMS or equivalent)
- Test restores quarterly as part of HIPAA compliance validation

```yaml
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: cleanroom-output-backup
  namespace: velero
spec:
  schedule: "0 */4 * * *"
  template:
    includedNamespaces:
      - hipaa-cleanroom
    includedResources:
      - persistentvolumeclaims
      - persistentvolumes
    labelSelector:
      matchLabels:
        backup: cleanroom-output
    snapshotVolumes: true
    storageLocation: encrypted-s3
```

## 10. Summary Checklist

| Control | Implementation |
|---------|---------------|
| Non-root container | `runAsNonRoot: true`, `runAsUser: 1000` |
| No privilege escalation | `allowPrivilegeEscalation: false`, `drop: ALL` |
| Seccomp profile | `RuntimeDefault` |
| Network isolation | Deny-all egress + DNS/iRODS whitelist |
| Encrypted storage | Encrypted StorageClass for PVCs |
| Read-only input data | `readOnly: true` on input PVC mount |
| No kubectl exec | RBAC role excludes `pods/exec`, `pods/attach`, `pods/portforward` |
| Session time limit | 8h max via CronJob reaper + KasmVNC `active_user_session_timeout` |
| Idle timeout | 15min via KasmVNC `idle_timeout` + `inactive_user_session_timeout` |
| Audit logging | K8s audit policy for exec/attach/secrets in namespace |
| Node isolation | Taints, tolerations, anti-affinity on dedicated HIPAA nodes |
| Image integrity | Cosign signing + Kyverno admission + Trivy scanning |
| Backup | Velero scheduled PVC snapshots to encrypted storage |
