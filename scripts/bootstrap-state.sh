#!/bin/bash

# Configuração
BUCKET_NAME="terraform-remote-state-$(date +%s)"
NAMESPACE=$(oci os ns get --query 'data' --raw-output)
COMPARTMENT_ID=$1

if [ -z "$COMPARTMENT_ID" ]; then
    echo "Uso: ./bootstrap-state.sh <compartment_ocid>"
    exit 1
fi

echo "Criando bucket $BUCKET_NAME no namespace $NAMESPACE..."

oci os bucket create \
    --compartment-id "$COMPARTMENT_ID" \
    --name "$BUCKET_NAME" \
    --versioning Enabled

echo "Bucket criado com sucesso."
echo "Atualize seu backend.tf com os seguintes detalhes:"
echo "bucket = \"$BUCKET_NAME\""
echo "namespace = \"$NAMESPACE\""
