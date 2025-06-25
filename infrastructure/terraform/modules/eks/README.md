# Módulo EKS - Kubernetes Cluster

## Descripción
Cluster Amazon EKS con worker nodes distribuidos en múltiples AZs para alta disponibilidad y escalabilidad automática.

## Características
- **EKS Cluster** v1.33 con control plane administrado
- **Worker Nodes** en subnets privadas para seguridad
- **Auto Scaling** configurado (min: 2, max: 6, desired: 3)
- **Multi-AZ deployment** para tolerancia a fallas
- **IAM Roles** usando LabRole de AWS Academy

## Componentes
- **EKS Cluster** con endpoint público y privado
- **Node Group** con instancias t3.medium
- **Auto Scaling Group** para nodos dinámicos
- **Security Groups** para control plane y workers

## Configuración de Red
- **Control Plane** - Acceso público y privado habilitado
- **Worker Nodes** - Solo en subnets privadas
- **Comunicación** - Segura entre control plane y workers
- **LoadBalancer Services** - Crean Classic Load Balancer automáticamente

## Uso
```hcl
module "eks" {
  source = "../../modules/eks"

  project_name                    = var.project_name
  cluster_name                    = var.cluster_name
  cluster_version                 = "1.33"
  private_subnet_ids              = module.vpc.private_subnet_ids
  control_plane_security_group_id = module.security.eks_control_plane_security_group_id

  # Configuración de nodos
  instance_types   = ["t3.medium"]
  desired_capacity = 3
  max_capacity     = 6
  min_capacity     = 2
}
```

## Escalabilidad
- **Horizontal Pod Autoscaler** - Escala pods basado en CPU/memoria
- **Cluster Autoscaler** - Agrega/quita nodos automáticamente
- **Manual Scaling** - Modificación de desired_capacity

## Conexión
```bash
# Configurar kubectl
aws eks update-kubeconfig --region us-east-1 --name CLUSTER_NAME

# Verificar conexión
kubectl get nodes
kubectl get pods --all-namespaces
```

## Outputs
- `cluster_name` - Nombre del cluster EKS
- `cluster_endpoint` - Endpoint del cluster
- `cluster_security_group_id` - ID del security group