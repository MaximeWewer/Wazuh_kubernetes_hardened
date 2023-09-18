# Wazuh : Kubernetes deployement hardened

Deploy a Wazuh cluster with a hardened (prod. ready) stack on Kubernetes. This deployement respect almost all Kubernetes security best pratices deployement and let you to configure more deeply your Wazuh cluster. 

You can configure :

- Wazuh :
    - Dashboard
    - API
    - Filebeat
    - Local options

- Opensearch :
    - Dashboard
    - Internal users
    - RBAC: Roles / Roles mapping
    - SSO

Even if your Wazuh deployment is more secure, you still need to make sure to cover Kubernetes cluster security :
- Node up to date
- Set up your firewall
- Secure your Etcd
- Scan your images
- Auditing and logging
- Define policy to automate backup & restore
- Etc

### Deployment
#### Specific local tests
- A local Kubernetes environment (1.25+) with Minikube, Microk8s, Kind, ...
- Use an alias for convenience ex: `alias kubectl="minikube kubectl --"`
- Modify PersistentVolume `local.path`

#### Specific prod deployment
- A Kubernetes cluster (1.25+)
- Modify StorageClass, PersistentVolume and PersistentVolumeClaim with your storage provider

#### For both
- Clone this repo
- Provide your certs or generate them using this script `certs/certs_generator.sh` (change Distinguished Name (DN) in script and in `opensearch.yml`)
- Generate and change secrets in `secrets`. You should use a third party secret manager as Vault Hashicrop to inject secrets
- Check network policies for exposed services (Wazuh, Wazuh API, Dashboard)
- Adapt resources requests/limits for containers
- Adapt RBAC to your cluster
- Perform deployment with [Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/) : `kubectl apply -k .`

#### Accessing Dashboard
You can setup your reverse proxy / HA proxy / API gateway or use port-forward (for tests) : `kubectl -n wazuh port-forward service/wazuh-dashboard 5601:5601`

 ### Directory structure
```bash
├── README.md
├── base
│   ├── ns.yml
│   ├── pv-opensearch.yml
│   ├── pv-wazuh.yml
│   ├── pvc-opensearch.yml
│   ├── pvc-wazuh.yml
│   └── storage-class.yml
├── certs
│   ├── certs_generator.sh
│   └── out
├── kustomization.yml
├── network-policies
│   ├── network-policy-514.yml
│   ├── network-policy-1514.yml
│   ├── network-policy-1515.yml
│   ├── network-policy-1516.yml
│   ├── network-policy-5601.yml
│   ├── network-policy-9200.yml
│   ├── network-policy-9300.yml
│   ├── network-policy-55000.yml
│   ├── network-policy-deny_all.yml
├── opensearch
│   ├── dashboard
│   │   ├── conf
│   │   │   ├── opensearch_dashboards.yml
│   │   │   └── wazuh_dashboard.yml
│   │   ├── dashboard-deploy.yml
│   │   └── dashboard-svc.yml
│   └── indexer
│       ├── conf
│       │   ├── config.yml
│       │   ├── internal_users.yml
│       │   ├── opensearch.yml
│       │   ├── roles.yml
│       │   └── roles_mapping.yml
│       ├── indexer-api-svc.yml
│       ├── indexer-sts.yml
│       └── indexer-svc.yml
├── rbac
│   ├── role-configmaps.yml
│   ├── role-deployments.yml
│   ├── role-pods.yml
│   ├── role-secrets.yml
│   ├── role-services.yml
│   ├── rolebinding-configmaps.yml
│   ├── rolebinding-deployments.yml
│   ├── rolebinding-pods.yml
│   ├── rolebinding-secrets.yml
│   ├── rolebinding-services.yml
│   └── service-account.yml
├── secrets
│   ├── indexer-secret-bcrypt.yml
│   ├── indexer-secret.yml
│   ├── wazuh-api-secret.yml
│   ├── wazuh-authd-secret.yml
│   └── wazuh-cluster-secret.yml
└── wazuh
    ├── conf
    │   ├── local_internal_options.conf
    │   ├── manager.conf
    │   └── worker.conf
    ├── filebeat
    │   ├── alerts_manifest.yml
    │   ├── archives_manifest.yml
    │   ├── filebeat.yml
    │   ├── wazuh-template.json
    │   └── wazuh_alerts_pipeline.json
    ├── wazuh-cluster-svc.yml
    ├── wazuh-manager-sts.yml
    ├── wazuh-manager-svc.yml
    ├── wazuh-worker-sts.yml
    └── wazuh-worker-svc.yml
```

### Clean Up

For delete Wazuh deployement : `kubectl delete -k .`

For delete PV : `kubectl get persistentvolume -n wazuh` and `kubectl delete persistentvolume pvc-<id>`