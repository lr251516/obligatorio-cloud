# Obligatorio de Implementación de Soluciones Cloud 2025

Migración de e-commerce PHP a Amazon EKS con arquitectura cloud-native tolerante a fallas.

## 🎯 Objetivos del Proyecto

Migrar un e-commerce PHP desde infraestructura on-premise a AWS, implementando:
- Alta disponibilidad y tolerancia a fallas
- Escalabilidad automática ante picos de tráfico
- Arquitectura cloud-native con Kubernetes
- IaC con Terraform

## 🏗️ Arquitectura

- **EKS Cluster** con Multi-AZ deployment
- **Application Load Balancer** para distribución de tráfico
- **RDS MySQL Multi-AZ** para alta disponibilidad de datos
- **Auto Scaling** (HPA + Cluster Autoscaler)
- **Security Groups** restrictivos
- **Terraform Modules** para infrastructure as code

## 🚀 Quick Start

1. [Prerrequisitos](docs/deployment/prerequisites.md)
2. [Guía de Instalación](docs/deployment/installation-guide.md)
3. [Arquitectura Detallada](docs/architecture/README.md)

## 📊 Estructura del Proyecto
├── docs/                    # Documentación
├── infrastructure/
│   ├── terraform/          # IaC con Terraform modules
│   └── k8s/               # Manifiestos Kubernetes
├── application/            # Código PHP + Docker
└── scripts/               # Scripts de deployment

## 🔧 Stack Tecnológico

- **Cloud Provider**: AWS
- **Container Orchestration**: Amazon EKS (Kubernetes)
- **Infrastructure as Code**: Terraform
- **Application**: PHP 8.2 + Apache
- **Database**: Amazon RDS MySQL 8.0
- **Load Balancer**: Application Load Balancer (ALB)
- **Container Registry**: Amazon ECR

## 📈 Características Implementadas

- ✅ Alta disponibilidad (Multi-AZ)
- ✅ Escalabilidad automática
- ✅ Tolerancia a fallas
- ✅ Security best practices
- ✅ Monitoring y logging
- ✅ Infrastructure as Code
- ✅ CI/CD pipeline

## 🎓 Obligatorio Universidad ORT Uruguay

**Materia**: Implementación de Soluciones Cloud  
**Carrera**: Analista en Infraestructura Informática  
**Universidad**: ORT Uruguay  
**Fecha**: Junio 2025

## 📄 Licencia

MIT License - ver [LICENSE](LICENSE)
