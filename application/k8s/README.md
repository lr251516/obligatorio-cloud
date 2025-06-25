# Manifiestos Kubernetes - E-commerce PHP

## Descripción
Manifiestos de Kubernetes para desplegar la aplicación e-commerce PHP con alta disponibilidad, escalabilidad automática y configuración de producción.

## Arquitectura de Deployment
```
Internet → Classic Load Balancer → Service (LoadBalancer) → Pods
                                      ↓
                                 ConfigMap + Secrets
                                      ↓
                                   RDS MySQL
```

## Archivos de Configuración

### **namespace.yaml**
```yaml
# Namespace dedicado para aislamiento de recursos
apiVersion: v1
kind: Namespace
metadata:
  name: ecommerce
```
- **Propósito:** Aislamiento de recursos y organización
- **Beneficios:** Separación de ambientes, políticas de red

### **configmap.yaml**
```yaml
# Variables de configuración no sensibles
data:
  DB_HOST: "obligatorio-cloud-mysql.endpoint.rds.amazonaws.com"
  DB_NAME: "ecommerce"
  DB_PORT: "3306"
  APP_ENV: "production"
```
- **Propósito:** Configuración de aplicación
- **Contenido:** Variables de entorno, configuración PHP
- **Ventajas:** Separación de config del código

### **secret.yaml**
```yaml
# Credenciales y datos sensibles (base64)
data:
  DB_USER: YWRtaW4=        # admin
  DB_PASSWORD: YWRtaW4xMjM0 # admin1234
```
- **Propósito:** Manejo seguro de credenciales
- **Contenido:** Usuario/contraseña de base de datos
- **Seguridad:** Datos encriptados en etcd

### **deployment.yaml**
```yaml
# Deployment principal de la aplicación
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

**Características del Deployment:**
- **Replicas:** 3 pods para alta disponibilidad
- **Rolling Update:** Deploy sin downtime
- **Resource Limits:** CPU/memoria controlados
- **Health Checks:** Liveness y readiness probes
- **Image:** ECR registry con versionado

**Container Spec:**
```yaml
containers:
- name: ecommerce
  image: ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/ecommerce-php:latest
  ports:
  - containerPort: 80
  resources:
    requests:
      memory: "256Mi"
      cpu: "250m"
    limits:
      memory: "512Mi"
      cpu: "500m"
```

**Health Checks:**
```yaml
livenessProbe:
  httpGet:
    path: /health.php
    port: 80
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /health.php
    port: 80
  initialDelaySeconds: 5
  periodSeconds: 5
```

### **service.yaml**
```yaml
# Service principal con LoadBalancer AWS
spec:
  type: LoadBalancer
  ports:
  - name: http
    port: 80
    targetPort: http
    protocol: TCP
  selector:
    app: ecommerce-php
```
- **Propósito:** Exponer aplicación a internet directamente
- **Tipo:** LoadBalancer (crea Classic Load Balancer automáticamente en AWS)
- **Puerto:** 80 (HTTP)
- **Beneficios:** Configuración simple, sin setup adicional

### **service adicional - ecommerce-health**
```yaml
# Service para health checks
spec:
  type: ClusterIP
  ports:
  - name: health
    port: 80
    targetPort: http
```
- **Propósito:** Health checks separados del CLB principal
- **Tipo:** ClusterIP (interno)
- **Uso:** Monitoreo y diagnóstico

### **hpa.yaml**
```yaml
# Horizontal Pod Autoscaler
spec:
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        averageUtilization: 70
```
- **Propósito:** Escalado automático basado en métricas
- **Métricas:** CPU 70%, Memory 80%
- **Rango:** 2-10 replicas

## Flujo de Deployment

### **1. Aplicar con script automatizado:**
```bash
# El script genera manifiestos dinámicos y aplica automáticamente
./application/scripts/deploy-to-eks.sh

# O manualmente en orden:
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml  
kubectl apply -f hpa.yaml
```

**Nota:**  El Service tipo LoadBalancer crea automáticamente un Classic Load Balancer en AWS

### **2. Verificar deployment:**
```bash
# Ver todos los recursos
kubectl get all -n ecommerce

# Ver pods en detalle
kubectl describe pods -n ecommerce

# Ver logs
kubectl logs -f deployment/ecommerce-php -n ecommerce
```

### **3. Verificar conectividad:**
```bash
# Port forward para testing
kubectl port-forward svc/ecommerce-service 8080:80 -n ecommerce

# Verificar health endpoint
curl http://localhost:8080/health.php
```

## Configuración de Recursos

### **Resource Requests/Limits:**
| Recurso | Request | Limit | Propósito |
|---------|---------|-------|-----------|
| CPU | 250m | 500m | Garantía mínima/máximo |
| Memory | 256Mi | 512Mi | Evitar OOM kills |

### **Configuración HPA:**
| Métrica | Threshold | Acción |
|---------|-----------|--------|
| CPU | 70% | Scale up |
| Memory | 80% | Scale up |
| Min Replicas | 2 | Disponibilidad mínima |
| Max Replicas | 10 | Límite de costo |

## Troubleshooting

### **Comandos útiles:**
```bash
# Ver estado general
kubectl get pods,svc -n ecommerce

# Obtener URL del Classic Load Balancer
kubectl get service ecommerce-service -n ecommerce -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Debug de pod específico
kubectl describe pod POD_NAME -n ecommerce
kubectl logs POD_NAME -n ecommerce

# Verificar configuración
kubectl get configmap ecommerce-config -o yaml -n ecommerce
kubectl get secret ecommerce-secrets -o yaml -n ecommerce

# Ver eventos
kubectl get events -n ecommerce --sort-by='.lastTimestamp'
```

### **Problemas comunes:**
- **ImagePullBackOff:** Verificar ECR permissions
- **CrashLoopBackOff:** Revisar logs del container
- **Pending pods:** Verificar resource requests vs capacity
- **Service unreachable:** Verificar selectors y ports

## Actualización de la Aplicación

### **Rolling Update:**
```bash
# Actualizar imagen
kubectl set image deployment/ecommerce-php ecommerce=NEW_IMAGE:TAG -n ecommerce

# Verificar rollout
kubectl rollout status deployment/ecommerce-php -n ecommerce

# Rollback si es necesario
kubectl rollout undo deployment/ecommerce-php -n ecommerce
```

### **Scaling Manual:**
```bash
# Escalar pods
kubectl scale deployment ecommerce-php --replicas=5 -n ecommerce

# Verificar HPA
kubectl get hpa -n ecommerce
```