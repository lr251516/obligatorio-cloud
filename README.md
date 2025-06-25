# 🚀 Obligatorio de Implementación de Soluciones Cloud 2025

Migración de e-commerce PHP a Amazon EKS con arquitectura cloud-native tolerante a fallas.

## 📋 Tabla de Contenidos

- [🎯 Objetivos del Proyecto](#-objetivos-del-proyecto)
- [🏗️ Arquitectura](#️-arquitectura)
- [📊 Estructura del Proyecto](#-estructura-del-proyecto)
- [🔧 Stack Tecnológico](#-stack-tecnológico)
- [🚀 Guía de Implementación](#-guía-de-implementación)
- [📈 Características Implementadas](#-características-implementadas)
- [🧪 Testing y Verificación](#-testing-y-verificación)
- [📚 Documentación](#-documentación)

## 🎯 Objetivos del Proyecto

Este proyecto implementa la migración de un e-commerce PHP desde infraestructura on-premise hacia AWS, cumpliendo con los siguientes objetivos:

### Requerimientos Académicos
- **Materia**: Implementación de Soluciones Cloud
- **Carrera**: Analista en Infraestructura Informática
- **Universidad**: ORT Uruguay
- **Entrega**: 26 de Junio 2025

### Objetivos Técnicos
- ✅ **Alta disponibilidad** y tolerancia a fallas Multi-AZ
- ✅ **Escalabilidad automática** ante picos de tráfico
- ✅ **Arquitectura cloud-native** con Kubernetes y contenedores
- ✅ **Infrastructure as Code** completamente automatizada
- ✅ **Security best practices** con grupos de seguridad restrictivos
- ✅ **Acceso administrativo seguro** con bastion host

## 🏗️ Arquitectura

### Diagrama de Arquitectura

![Diagrama de Arquitectura AWS](docs/architecture/diagrama-arquitectura.png)

### Componentes Principales

El diagrama muestra una **arquitectura de 3 capas** altamente disponible:

**🌐 Capa de Red (Networking Layer)**
- **Internet Gateway** para conectividad externa
- **NAT Gateways** redundantes en cada AZ para salida segura
- **VPC Multi-AZ** con separación por función (10.0.0.0/16)

**⚖️ Capa de Aplicación (Application Layer)**
- **Classic Load Balancer** creado automáticamente por Kubernetes
- **EKS Control Plane** gestionado por AWS (multi-AZ automático)
- **Worker Nodes** en subnets privadas con Auto Scaling Groups
- **PHP Pods** escalando automáticamente según demanda
- **Bastion Host** para administración segura

**💾 Capa de Datos (Data Layer)**  
- **RDS MySQL Multi-AZ** con primary/standby automático
- **Subnets de base de datos** aisladas para máxima seguridad
- **Backup automático** con 7 días de retención

**🛡️ Servicios Complementarios**
- **Amazon ECR** para registry de imágenes Docker
- **Security Groups** restrictivos por componente
- **AWS Academy** compatibility para entorno educativo

## 📊 Estructura del Proyecto

```
obligatorio-cloud/
├── 📁 docs/                           # Documentación técnica
│   └── architecture/                  # Diagramas y diseño
├── 📁 infrastructure/                 # Infrastructure as Code
│   └── terraform/                     # Módulos Terraform
│       ├── modules/                   # Módulos reutilizables
│       │   ├── vpc/                   # Configuración de red Multi-AZ
│       │   ├── eks/                   # Cluster Kubernetes
│       │   ├── rds/                   # Base de datos MySQL
│       │   ├── security/              # Grupos de seguridad
│       │   └── bastion/               # Host de administración
│       └── environments/              # Configuraciones por ambiente
│           └── prod/                  # Ambiente de producción
├── 📁 application/                    # Aplicación e-commerce
│   ├── src/                           # Código fuente PHP
│   ├── docker/                        # Dockerfile optimizado
│   ├── k8s/                           # Manifiestos Kubernetes
│   └── scripts/                       # Scripts de automatización
└── 📁 .gitignore, README.md, etc.     # Archivos raíz
```

## 🔧 Stack de Tecnologías

### ☁️ Cloud Provider
- **AWS** como proveedor principal
- **Multi-AZ deployment** para alta disponibilidad
- **Region**: us-east-1 
- **AWS Academy** compatible para entorno educativo

### 🏗️ Infrastructure as Code
- **Terraform** con módulos personalizados
- **State management** local para AWS Academy
- **Configuración declarativa** de toda la infraestructura

### 🐳 Containerización
- **Docker** para empaquetado de aplicación
- **Amazon ECR** como registry de imágenes
- **PHP 8.2 + Apache** optimizado para producción

### ⚙️ Orquestación
- **Amazon EKS** (Kubernetes 1.33)
- **Managed Node Groups** para worker nodes
- **Classic Load Balancer** vía Service LoadBalancer
- **Horizontal Pod Autoscaler** para escalado automático

### 💻 Aplicación
- **PHP 8.2** con Apache como web server
- **MySQL 8.0** como base de datos
- **Configuración cloud-native** con variables de entorno

### 🔧 Herramientas DevOps
- **AWS CLI** para interacción con servicios
- **kubectl** para gestión de Kubernetes
- **Scripts bash** para automatización de deployment

## 🚀 Guía de Implementación

### 📋 Prerrequisitos

1. **AWS Academy Lab** activo:
   ```bash
   # Iniciar lab de AWS Academy
   # Obtener credenciales temporales
   # Descargar vockey.pem key pair
   ```

2. **Herramientas requeridas**:
   ```bash
   # AWS CLI
   aws --version          # >= 2.0
   
   # Terraform
   terraform --version    # >= 1.5
   
   # Docker
   docker --version       # >= 20.0
   
   # kubectl
   kubectl version        # >= 1.28
   ```

3. **Configuración AWS Academy**:
   ```bash
   # Configurar credenciales temporales de AWS Academy
   aws configure set aws_access_key_id ASIA...
   aws configure set aws_secret_access_key ...
   aws configure set aws_session_token ...
   aws configure set region us-east-1
   
   # Configurar vockey key pair
   cp vockey.pem ~/.ssh/vockey.pem
   chmod 400 ~/.ssh/vockey.pem
   ```

### 🏗️ Paso 1: Desplegar Infraestructura

```bash
# 1. Clonar repositorio
git clone https://github.com/lr251516/obligatorio-cloud.git
cd obligatorio-cloud

# 2. Navegar a directorio de Terraform
cd infrastructure/terraform/environments/prod

# 3. Configurar variables (crear terraform.tfvars)
echo 'key_pair_name = "vockey"' > terraform.tfvars

# 4. Inicializar Terraform
terraform init

# 5. Planificar cambios
terraform plan

# 6. Aplicar infraestructura
terraform apply
```

### 🐳 Paso 2: Build y Push de Imagen Docker

```bash
# Navegar a directorio de aplicación
cd application/

# Ejecutar script de build y push automatizado
./scripts/build-and-push.sh

# O manualmente:
# 1. Build de imagen
docker build -f docker/Dockerfile -t ecommerce-php .

# 2. Tag para ECR
docker tag ecommerce-php:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/ecommerce-php:latest

# 3. Push a ECR
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/ecommerce-php:latest
```

### ⚓ Paso 3: Deploy a Kubernetes

```bash
# Ejecutar script de deploy automatizado
./scripts/deploy-to-eks.sh

# El script automáticamente:
# 1. Configura kubectl con el cluster EKS
# 2. Genera manifests con valores dinámicos de Terraform
# 3. Aplica los recursos a Kubernetes
# 4. Verifica el deployment
```

### 🌐 Paso 4: Verificar Funcionamiento

```bash
# Obtener URL del Classic Load Balancer
kubectl get service ecommerce-service -n ecommerce -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Verificar pods
kubectl get pods -n ecommerce

# Ver logs de aplicación
kubectl logs -f deployment/ecommerce-php -n ecommerce
```

### 🗄️ Paso 5: Acceso a Base de Datos (via Bastion)

```bash
# Obtener IP del bastion
terraform output bastion_public_ip

# SSH al bastion
ssh -i ~/.ssh/vockey.pem ec2-user@BASTION_IP

# Conectar a MySQL desde el bastion
./connect-mysql.sh
```

## 📈 Características Implementadas

### 🔄 Alta Disponibilidad
- **Multi-AZ deployment** en us-east-1a y us-east-1b
- **RDS Multi-AZ** con failover automático
- **EKS worker nodes** distribuidos geográficamente
- **Classic Load Balancer** con health checks automáticos

### 📊 Escalabilidad Automática
- **Horizontal Pod Autoscaler (HPA)** basado en CPU/memoria
- **Auto Scaling Groups** para worker nodes de EKS
- **Configuración dinámica** de réplicas (2-10 pods)

### 🛡️ Seguridad
- **Security Groups** restrictivos por componente:
  - CLB: Solo puertos 80/443 desde Internet
  - EKS Nodes: Solo tráfico desde CLB y control plane
  - RDS: Solo puerto 3306 desde EKS nodes y bastion
  - Bastion: Solo SSH desde Internet
- **Kubernetes Secrets** para credentials sensibles
- **Network isolation** entre capas de aplicación
- **Bastion host** para acceso administrativo seguro

### 🔧 Automatización
- **Infrastructure as Code** 100% con Terraform
- **Scripts automatizados** para build y deploy
- **Configuration as Code** con Kubernetes manifests
- **Gestión de secrets** automatizada
- **Deployment dinámico** con valores de Terraform

### 📱 Monitoring & Logging
- **Health checks** en múltiples niveles
- **Kubernetes native logging** con kubectl
- **Readiness y liveness probes** configurados
- **Performance Insights** habilitado en RDS

## 🧪 Testing y Verificación

### ✅ Verificación de Infraestructura
```bash
# Verificar que todos los recursos estén creados
terraform output

# Comprobar estado del cluster EKS
aws eks describe-cluster --name obligatorio-eks-cluster

# Verificar RDS Multi-AZ
aws rds describe-db-instances --db-instance-identifier db-obligatorio
```

### ✅ Verificación de Aplicación
```bash
# Estado de pods
kubectl get pods -n ecommerce -o wide

# Estado de servicios y load balancer
kubectl get svc -n ecommerce

# Logs de aplicación
kubectl logs -f deployment/ecommerce-php -n ecommerce

# Test de conectividad a base de datos
kubectl exec -it deployment/ecommerce-php -n ecommerce -- php -r "
  include '/var/www/html/views/db.php';
  echo 'Conexión exitosa a: ' . \$host;
"
```

### ✅ Test de Load Balancer
```bash
# Obtener URL del Classic Load Balancer
LB_URL=$(kubectl get service ecommerce-service -n ecommerce -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Test de conectividad
curl -I http://$LB_URL

# Verificar aplicación funcionando
curl http://$LB_URL
```

### ✅ Test de Bastion y RDS
```bash
# Test de conectividad SSH al bastion
ssh -i ~/.ssh/vockey.pem ec2-user@$(terraform output -raw bastion_public_ip)

# Test de conectividad MySQL desde bastion
ssh -i ~/.ssh/vockey.pem ec2-user@$(terraform output -raw bastion_public_ip) './test-mysql.sh'
```

## 📚 Documentación

### 📖 Documentos Incluidos
- **README principal** - Guía completa del proyecto
- **Módulos Terraform** - Documentación individual de cada módulo
- **Manifiestos K8s** - Explicación de cada recurso Kubernetes
- **Scripts de automatización** - Guías de uso y troubleshooting

### 🔍 Comandos Útiles

**Terraform**:
```bash
terraform plan -out=tfplan  # Planificar cambios
terraform apply tfplan      # Aplicar plan
terraform output            # Ver outputs de infraestructura
terraform destroy           # Destruir infraestructura (cuidado!)
```

**Kubernetes**:
```bash
kubectl get all -n ecommerce                     # Ver todos los recursos
kubectl describe pod <pod-name> -n ecommerce     # Detalles de pod
kubectl logs -f <pod-name> -n ecommerce          # Logs en tiempo real
kubectl exec -it <pod-name> -n ecommerce -- bash # Acceso shell
kubectl get hpa -n ecommerce                     # Ver auto scaling
```

**Docker**:
```bash
docker images                      # Listar imágenes
docker ps                         # Contenedores activos
docker logs <container-id>        # Ver logs
```

**AWS CLI**:
```bash
aws eks describe-cluster --name obligatorio-eks-cluster    # Info del cluster
aws rds describe-db-instances                              # Info de RDS
aws ec2 describe-instances --filters "Name=tag:Name,Values=*bastion*" # Info bastion
```

### 🚨 Troubleshooting Común

**Problema**: Pods en estado `ImagePullBackOff`  
**Solución**: Verificar que la imagen esté en ECR y las credenciales sean correctas

**Problema**: No se puede conectar a RDS  
**Solución**: Verificar security groups y usar bastion host para acceso

**Problema**: Classic Load Balancer no responde  
**Solución**: Verificar health checks y que los pods estén en estado `Ready`

**Problema**: Credenciales de AWS Academy expiran  
**Solución**: Renovar sesión del lab y actualizar credenciales con `aws configure`

**Problema**: No se puede hacer SSH al bastion  
**Solución**: Verificar que vockey.pem tenga permisos 400 y la IP del bastion

## 🎓 Información Académica

### Universidad ORT Uruguay
- **Materia**: Implementación de Soluciones Cloud (ISC)
- **Carrera**: Analista en Infraestructura Informática
- **Año**: 2025
- **Modalidad**: Obligatorio grupal

### Criterios de Evaluación Cumplidos
- ✅ **Tolerancia a fallas** - Multi-AZ deployment
- ✅ **Escalabilidad ante picos** - HPA y Auto Scaling
- ✅ **Firewall restrictivo** - Security Groups por capas
- ✅ **Mejoras propuestas** - Bastion host, contenedores, IaC
- ✅ **Documentación completa** - README y documentación técnica
- ✅ **Trabajo colaborativo** - Git con commits organizados

## 📄 Licencia

MIT License - Este proyecto está disponible bajo la licencia MIT para fines educativos.

---