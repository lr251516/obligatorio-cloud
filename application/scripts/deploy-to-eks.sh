#!/bin/bash

# Script de Deploy a EKS desde los outputs de Terraform

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging con colores
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Configuración
TERRAFORM_DIR="../infrastructure/terraform/environments/prod"
K8S_DIR="k8s"
NAMESPACE="ecommerce"

log "🚀 Iniciando deploy a EKS con valores dinámicos de Terraform"

# Verificar dependencias
check_dependencies() {
    log "🔍 Verificando dependencias..."
    
    if ! command -v kubectl &> /dev/null; then
        error "kubectl no está instalado"
        exit 1
    fi
    
    if ! command -v terraform &> /dev/null; then
        error "terraform no está instalado"
        exit 1
    fi

    if ! command -v curl &> /dev/null; then
    error "curl no está instalado"
    exit 1
    fi
    
    success "Dependencias verificadas"
}

# Obtener outputs de Terraform
get_terraform_outputs() {
    log "📊 Obteniendo outputs de Terraform..."
    
    cd "$TERRAFORM_DIR"
    
    # Verificar que existe terraform state
    if [ ! -f "terraform.tfstate" ]; then
        error "No se encontró terraform.tfstate. Ejecuta 'terraform apply' primero."
        exit 1
    fi
    
    # Obtener valores
    export DB_ENDPOINT=$(terraform output -raw db_endpoint)
    export DB_NAME=$(terraform output -raw db_name)
    export DB_PORT=$(terraform output -raw db_port)
    export CLUSTER_NAME=$(terraform output -raw cluster_name)
    export VPC_ID=$(terraform output -raw vpc_id)
    
    # Separar host y puerto si DB_ENDPOINT incluye el puerto
    if [[ "$DB_ENDPOINT" == *:* ]]; then
      export DB_HOST="$(echo $DB_ENDPOINT | cut -d: -f1)"
      export DB_PORT="$(echo $DB_ENDPOINT | cut -d: -f2)"
    else
      export DB_HOST="$DB_ENDPOINT"
    fi
    
    # Obtener valores sensibles
    export DB_USERNAME=$(terraform output -raw db_username 2>/dev/null || echo "admin")
    export DB_PASSWORD=$(terraform output -raw db_password 2>/dev/null || echo "admin1234")

    
    cd - > /dev/null
    
    success "Valores obtenidos de Terraform:"
    log "   - DB Endpoint: $DB_ENDPOINT"
    log "   - DB Name: $DB_NAME"
    log "   - Cluster: $CLUSTER_NAME"
    log "   - VPC ID: $VPC_ID"
}

# Configurar kubectl para EKS
configure_kubectl() {
    log "⚙️  Configurando kubectl para EKS..."
    
    aws eks update-kubeconfig --region us-east-1 --name "$CLUSTER_NAME"
    
    # Verificar conexión
    if kubectl get nodes > /dev/null 2>&1; then
        success "Conexión a EKS establecida"
        kubectl get nodes
    else
        error "No se pudo conectar al cluster EKS"
        exit 1
    fi
}

# Generar manifests con valores dinámicos
generate_manifests() {
    log "📝 Generando manifests con valores dinámicos..."
    
    # Crear directorio temporal
    TEMP_DIR="k8s-generated"
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"
    
    # Copiar manifests base
    cp -r "$K8S_DIR"/. "$TEMP_DIR"/
    
    # Reemplazar placeholders en configmap.yaml
    sed -i.bak "s|DB_HOST_PLACEHOLDER|$DB_HOST|g" "$TEMP_DIR/configmap.yaml"
    sed -i.bak "s|DB_NAME_PLACEHOLDER|$DB_NAME|g" "$TEMP_DIR/configmap.yaml"
    sed -i.bak "s|DB_PORT_PLACEHOLDER|$DB_PORT|g" "$TEMP_DIR/configmap.yaml"
    
    # Generar secret con valores reales
    DB_USER_B64=$(echo -n "$DB_USERNAME" | base64)
    DB_PASS_B64=$(echo -n "$DB_PASSWORD" | base64)
    
    # Actualizar secret.yaml
    sed -i.bak "s|username: .*|username: $DB_USER_B64|g" "$TEMP_DIR/secret.yaml"
    sed -i.bak "s|password: .*|password: $DB_PASS_B64|g" "$TEMP_DIR/secret.yaml"
    
    # Obtener Account ID para ECR
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    ECR_IMAGE="${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/ecommerce-php:latest"
    
    # Actualizar deployment.yaml con imagen ECR real
    sed -i.bak "s|ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/ecommerce-php:latest|$ECR_IMAGE|g" "$TEMP_DIR/deployment.yaml"
    
    # Limpiar archivos backup
    rm -f "$TEMP_DIR"/*.bak
    
    success "Manifests generados en $TEMP_DIR/"
    export MANIFEST_DIR="$TEMP_DIR"
}

# Aplicar manifests a Kubernetes
apply_manifests() {
    log "🚀 Aplicando manifests a Kubernetes..."
    
    # Lista de manifiestos a aplicar en orden
    manifests=(namespace.yaml secret.yaml configmap.yaml deployment.yaml service.yaml hpa.yaml)
    for manifest in "${manifests[@]}"; do
        if [ ! -f "$MANIFEST_DIR/$manifest" ]; then
            error "No se encontró el manifiesto: $MANIFEST_DIR/$manifest"
            exit 1
        fi
        if kubectl apply -f "$MANIFEST_DIR/$manifest"; then
            log "✅ Aplicado: $manifest"
        else
            error "Fallo al aplicar: $manifest"
            exit 1
        fi
    done
    
    success "Manifests aplicados"
}

# Verificar deployment
verify_deployment() {
    log "🔍 Verificando deployment..."
    
    # Esperar a que los pods estén listos
    log "⏳ Esperando que los pods estén listos..."
    kubectl wait --for=condition=ready pod -l app=ecommerce-php -n "$NAMESPACE" --timeout=300s
    
    # Mostrar status
    log "📊 Estado del deployment:"
    kubectl get pods -n "$NAMESPACE"
    kubectl get services -n "$NAMESPACE"
    kubectl get hpa -n "$NAMESPACE"
    
    success "Deployment verificado exitosamente"
}

# Cleanup
cleanup() {
    log "🧹 Limpiando archivos temporales..."
    rm -rf "$MANIFEST_DIR"
}

# Instalar Metrics Server si no existe
install_metrics_server() {
    if ! kubectl get deployment metrics-server -n kube-system &>/dev/null; then
        log "⚙️  Instalando Metrics Server en el clúster..."
        kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
        # Parchear para EKS
        kubectl -n kube-system patch deployment metrics-server \
          --type='json' -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
        log "✅ Metrics Server instalado y parcheado para EKS."
    else
        log "✅ Metrics Server ya está instalado."
    fi
}

# Función principal
main() {
    log "🎯 Deploy de E-commerce PHP a EKS"
    echo

    install_metrics_server
    check_dependencies
    get_terraform_outputs
    configure_kubectl
    generate_manifests
    apply_manifests
    verify_deployment
    cleanup
    
    echo
    success "🎉 ¡Deploy completado exitosamente!"
    log "🌍 Para acceder a la aplicación, obtén la URL del Load Balancer:"
    log "    kubectl get service ecommerce-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

# Ejecutar script principal
main "$@"
