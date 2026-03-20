#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="../Kubernetes/backend-services"

if [ $# -ne 1 ]; then
  echo "Usage: ./update-image-tags.sh <new-version>"
  echo "Example: ./update-image-tags.sh 1.0.6"
  exit 1
fi

NEW_TAG="$1"

echo "Updating all backend service image tags to: $NEW_TAG"
echo ""

find "$BASE_DIR" -name "deployment.yaml" | while read -r file; do
    echo "Processing $file"

    sed -i -E "s|(image:\s*princewillopah2/luxecart-[^:]+:)[^[:space:]]+|\1${NEW_TAG}|g" "$file"
done

echo ""
echo "All image tags updated successfully."