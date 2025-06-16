#!/bin/bash

# Script para construir y subir una imagen Docker a AWS ECR

set -e

# Configuración
AWS_REGION="us-east-1"
ECR_REPOSITORY="ecommerce-php"
IMAGE_TAG="latest"
DOCKERFILE_PATH="docker/Dockerfile"

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

# Función para verificar dependencias
check_dependencies() {
    log "Verificando dependencias..."
    
    # Verificar AWS CLI
    if ! command -v aws &> /dev/null; then
        error "AWS CLI no está instalado"
        echo "Instala con: pip install awscli"
        exit 1
    fi
    
    # Verificar Docker
    if ! command -v docker &> /dev/null; then
        error "Docker no está instalado"
        exit 1
    fi
    
    # Verificar si Docker está ejecutándose
    if ! docker info &> /dev/null; then
        error "Docker no está ejecutándose"
        exit 1
    fi
    
    success "Dependencias verificadas"
}

# Función para obtener información de AWS
get_aws_info() {
    log "🔍 Obteniendo información de AWS..."
    
    # Obtener Account ID
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "")
    if [ -z "$AWS_ACCOUNT_ID" ]; then
        error "No se pudo obtener AWS Account ID. ¿Está configurado AWS CLI?"
        echo "Configura con: aws configure"
        exit 1
    fi
    
    # Construir URL del registro ECR
    ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    FULL_IMAGE_NAME="${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
    
    success "AWS Account ID: $AWS_ACCOUNT_ID"
    success "ECR Registry: $ECR_REGISTRY"
    success "Imagen completa: $FULL_IMAGE_NAME"
}

# Función para crear repositorio ECR si no existe
create_ecr_repository() {
    log "Verificando repositorio ECR..."
    
    # Verificar si el repositorio existe
    if aws ecr describe-repositories --repository-names "$ECR_REPOSITORY" --region "$AWS_REGION" &>/dev/null; then
        success "Repositorio ECR ya existe: $ECR_REPOSITORY"
    else
        warning "Repositorio ECR no existe. Creando..."
        
        # Crear repositorio
        aws ecr create-repository \
            --repository-name "$ECR_REPOSITORY" \
            --region "$AWS_REGION" \
            --image-scanning-configuration scanOnPush=true \
            --encryption-configuration encryptionType=AES256
        
        success "Repositorio ECR creado: $ECR_REPOSITORY"
    fi
}

# Función para login en ECR
ecr_login() {
    log "Realizando login en ECR..."
    
    # Login en ECR
    aws ecr get-login-password --region "$AWS_REGION" | \
        docker login --username AWS --password-stdin "$ECR_REGISTRY"
    
    success "Login en ECR exitoso"
}

# Función para build de imagen
build_image() {
    log "Construyendo imagen Docker..."
    
    # Verificar que existe el Dockerfile
    if [ ! -f "$DOCKERFILE_PATH" ]; then
        error "Dockerfile no encontrado en: $DOCKERFILE_PATH"
        exit 1
    fi
    
    # Build de la imagen
    docker build \
        --platform linux/amd64 \
        -f "$DOCKERFILE_PATH" \
        -t "$ECR_REPOSITORY:$IMAGE_TAG" \
        -t "$FULL_IMAGE_NAME" \
        .
    
    success "Imagen construida exitosamente"
    
    # Mostrar información de la imagen
    log "Información de la imagen:"
    docker images "$ECR_REPOSITORY:$IMAGE_TAG" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
}

# Función para push a ECR
push_image() {
    log "Subiendo imagen a ECR..."
    
    # Push de la imagen
    docker push "$FULL_IMAGE_NAME"
    
    success "Imagen subida exitosamente a ECR"
    success "URI de la imagen: $FULL_IMAGE_NAME"
}

# Función para cleanup local
cleanup() {
    log "Limpieza opcional de imágenes locales..."
    
    read -p "¿Deseas eliminar la imagen local para ahorrar espacio? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker rmi "$ECR_REPOSITORY:$IMAGE_TAG" "$FULL_IMAGE_NAME" || true
        success "Imágenes locales eliminadas"
    else
        warning "Imágenes locales conservadas"
    fi
}

# Función para mostrar información final
show_summary() {
    echo
    echo "🎉 ¡Build y push completados exitosamente!"
    echo
    echo "Resumen:"
    echo "   - Repositorio ECR: $ECR_REPOSITORY"
    echo "   - Tag: $IMAGE_TAG"
    echo "   - URI completa: $FULL_IMAGE_NAME"
    echo "   - Región: $AWS_REGION"
    echo
    echo "Para usar en Kubernetes:"
    echo "   image: $FULL_IMAGE_NAME"
    echo
    echo "Ver en AWS Console:"
    echo "   https://$AWS_REGION.console.aws.amazon.com/ecr/repositories/$ECR_REPOSITORY"
}

# Función principal
main() {
    echo
    log "🐳 Iniciando build y push a AWS ECR"
    log "📋 Repositorio: $ECR_REPOSITORY"
    log "🏷️  Tag: $IMAGE_TAG"
    echo
    
    # Ejecutar pasos
    check_dependencies
    get_aws_info
    create_ecr_repository
    ecr_login
    build_image
    push_image
    cleanup
    show_summary
}

# Manejo de argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--region)
            AWS_REGION="$2"
            shift 2
            ;;
        -t|--tag)
            IMAGE_TAG="$2"
            shift 2
            ;;
        -n|--name)
            ECR_REPOSITORY="$2"
            shift 2
            ;;
        -h|--help)
            echo "Uso: $0 [opciones]"
            echo "Opciones:"
            echo "  -r, --region    Región de AWS (default: us-east-1)"
            echo "  -t, --tag       Tag de la imagen (default: latest)"
            echo "  -n, --name      Nombre del repositorio ECR (default: ecommerce-php)"
            echo "  -h, --help      Mostrar esta ayuda"
            exit 0
            ;;
        *)
            error "Opción desconocida: $1"
            exit 1
            ;;
    esac
done

# Ejecutar script principal
main "$@"