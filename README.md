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
- ✅ **Monitoreo y logging** integrados

## 🏗️ Arquitectura

### Diagrama de Arquitectura

![Diagrama de Arquitectura AWS](docs/architecture/diagrama-arquitectura.png)

### Componentes Principales

El diagrama muestra una **arquitectura de 3 capas** altamente disponible:

**🌐 Capa de Red (Networking Layer)**
- **Internet Gateway** para conectividad externa
- **NAT Gateways** redundantes en cada AZ para salida segura
- **Route 53** para resolución DNS (implícito)

**⚖️ Capa de Aplicación (Application Layer)**
- **Application Load Balancer** distribuido en subnets públicas
- **EKS Control Plane** gestionado por AWS (multi-AZ automático)
- **Worker Nodes** en subnets privadas con Auto Scaling Groups
- **PHP Pods** escalando automáticamente según demanda

**💾 Capa de Datos (Data Layer)**  
- **RDS MySQL Multi-AZ** con primary/standby automático
- **Subnets de base de datos** aisladas para máxima seguridad
- **Backup y replicación** automáticos

**🛡️ Servicios Complementarios**
- **S3 Buckets** para almacenamiento de assets estáticos
- **CloudWatch** para monitoreo y métricas
- **Security Groups** restrictivos por componente

## 📊 Estructura del Proyecto

```
obligatorio-cloud/
├── 📁 docs/                           # Documentación técnica
│   ├── architecture/                  # Diagramas y diseño
│   ├── deployment/                    # Guías de instalación
│   └── operations/                    # Manuales operativos
├── 📁 infrastructure/                 # Infrastructure as Code
│   ├── terraform/                     # Módulos Terraform
│   │   ├── modules/                   # Módulos reutilizables
│   │   │   ├── vpc/                   # Configuración de red
│   │   │   ├── eks/                   # Cluster Kubernetes
│   │   │   ├── rds/                   # Base de datos
│   │   │   └── security/              # Grupos de seguridad
│   │   └── environments/              # Configuraciones por ambiente
│   │       └── prod/                  # Ambiente de producción
│   └── k8s/                          # Recursos Kubernetes base
├── 📁 application/                    # Aplicación e-commerce
│   ├── src/                          # Código fuente PHP
│   ├── docker/                       # Dockerfile y configuración
│   ├── k8s/                         # Manifiestos Kubernetes
│   └── scripts/                      # Scripts de automatización
└── 📁 scripts/                       # Scripts de deployment
```

## 🔧 Stack de Tecnologías

### ☁️ Cloud Provider
- **AWS** como proveedor principal
- **Multi-AZ deployment** para alta disponibilidad
- **Region**: us-east-1 

### 🏗️ Infrastructure as Code
- **Terraform** 1.5+ para gestión de infraestructura
- **Módulos custom** para reutilización
- **State management** centralizado

### 🐳 Containerización
- **Docker** para empaquetado de aplicación
- **Amazon ECR** como registry de imágenes
- **Multi-stage builds** para optimización

### ⚙️ Orquestación
- **Amazon EKS** (Kubernetes 1.33)
- **Managed Node Groups** para worker nodes
- **AWS Load Balancer Controller** para ALB

### 💻 Aplicación
- **PHP 8.2** con Apache como web server
- **MySQL 8.0** como base de datos
- **Configuración cloud-native** con 12-factor app

### 🔧 Herramientas DevOps
- **AWS CLI** para interacción con servicios
- **kubectl** para gestión de Kubernetes
- **Scripts bash** para automatización

## 🚀 Guía de Implementación

### 📋 Prerrequisitos

1. **Herramientas requeridas**:
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

2. **Configuración AWS**:
   ```bash
   # Configurar credenciales
   aws configure
   
   # Verificar acceso
   aws sts get-caller-identity
   ```

### 🏗️ Paso 1: Desplegar Infraestructura

```bash
# 1. Clonar repositorio
git clone https://github.com/lr251516/obligatorio-cloud.git
cd obligatorio-cloud

# 2. Navegar a directorio de Terraform
cd infrastructure/terraform/environments/prod

# 3. Inicializar Terraform
terraform init

# 4. Planificar cambios
terraform plan

# 5. Aplicar infraestructura
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
# Obtener URL del Load Balancer
kubectl get service ecommerce-service -n ecommerce

# Verificar pods
kubectl get pods -n ecommerce

# Ver logs
kubectl logs -f deployment/ecommerce-app -n ecommerce
```

## 📈 Características Implementadas

### 🔄 Alta Disponibilidad
- **Multi-AZ deployment** en us-east-1a y us-east-1b
- **RDS Multi-AZ** con failover automático
- **EKS worker nodes** distribuidos geográficamente
- **Load Balancer** con health checks

### 📊 Escalabilidad Automática
- **Horizontal Pod Autoscaler (HPA)** basado en CPU/memoria
- **Cluster Autoscaler** para worker nodes
- **Configuración dinámica** de réplicas de 2-6 pods

### 🛡️ Seguridad
- **Security Groups** restrictivos por componente:
  - ALB: Solo puertos 80/443 desde Internet
  - EKS Nodes: Solo tráfico desde ALB
  - RDS: Solo puerto 3306 desde EKS nodes
- **Kubernetes Secrets** para credentials sensibles
- **Network isolation** entre layers

### 🔧 Automatización
- **Infrastructure as Code** 100% con Terraform
- **Scripts automatizados** para build y deploy
- **Configuration as Code** con Kubernetes manifests
- **Gestión de secrets** automatizada

### 📱 Monitoring & Logging
- **Health checks** en múltiples niveles
- **AWS CloudWatch** para métricas
- **Kubernetes native logging**
- **Readiness y liveness probes**

## 🧪 Testing y Verificación

### ✅ Verificación de Infraestructura
```bash
# Verificar que todos los recursos estén creados
terraform output

# Comprobar estado del cluster EKS
aws eks describe-cluster --name <cluster-name>

# Verificar RDS
aws rds describe-db-instances
```

### ✅ Verificación de Aplicación
```bash
# Estado de pods
kubectl get pods -n ecommerce -o wide

# Estado de servicios
kubectl get svc -n ecommerce

# Logs de aplicación
kubectl logs -f deployment/ecommerce-app -n ecommerce

# Test de conectividad a base de datos
kubectl exec -it deployment/ecommerce-app -n ecommerce -- php -r "
  \$conn = new PDO('mysql:host=\$_ENV[\"DB_HOST\"];dbname=\$_ENV[\"DB_NAME\"]', \$_ENV['DB_USER'], \$_ENV['DB_PASSWORD']);
  echo 'Conexión exitosa a base de datos';
"
```

### ✅ Test de Load Balancer
```bash
# Obtener URL del Load Balancer
LB_URL=$(kubectl get service ecommerce-service -n ecommerce -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Test de conectividad
curl -I http://$LB_URL
```

## 📚 Documentación

### 📖 Documentos Incluidos
- Prerrequisitos de Sistema
- Guía de Instalación Completa
- Arquitectura Detallada
- Manual de Troubleshooting

### 🔍 Comandos Útiles

**Terraform**:
```bash
terraform plan -out=tfplan  # Planificar cambios
terraform apply tfplan		# Aplicar plan
terraform destroy           # Destruir infraestructura
terraform output            # Ver outputs
```

**Kubernetes**:
```bash
kubectl get all -n ecommerce                    	# Ver todos los recursos
kubectl describe pod <pod-name> -n ecommerce        # Detalles de pod
kubectl logs -f <pod-name> -n ecommerce         	# Logs en tiempo real
kubectl exec -it <pod-name> -n ecommerce -- bash	# Acceso shell
```

**Docker**:
```bash
docker images                      	# Listar imágenes
docker ps                         	# Contenedores activos
docker logs <container-id>	        # Ver logs
```

### 🚨 Troubleshooting Común

**Problema**: Pods en estado `ImagePullBackOff`  
**Solución**: Verificar que la imagen esté en ECR y las credenciales sean correctas

**Problema**: No se puede conectar a RDS  
**Solución**: Verificar security groups y credenciales en secrets

**Problema**: Load Balancer no responde  
**Solución**: Verificar health checks y que los pods estén en estado `Ready`

## 📄 Licencia

MIT License - Este proyecto está disponible bajo la licencia MIT para fines educativos.