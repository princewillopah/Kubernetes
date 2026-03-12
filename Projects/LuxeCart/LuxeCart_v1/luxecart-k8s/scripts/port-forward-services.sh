#!/bin/bash

set -e

services=(
api-gateway-service:3000
auth-service:3001
user-service:3002
product-service:3003
cart-service:3004
order-service:3005
review-service:3006
rating-service:3007
payment-service:3008
notification-service:3009
admin-service:3010
inventory-service:3011
search-service:3012
analytics-service:3013
recommendation-service:3014
email-service:3015
)

for svc in "${services[@]}"
do
  name=$(echo $svc | cut -d: -f1)
  port=$(echo $svc | cut -d: -f2)

  echo "Starting port-forward for $name on $port"

  kubectl port-forward svc/$name $port:$port -n luxe-backend \
    > /tmp/${name}.log 2>&1 &
done

echo "All port-forwards started."


# ==================================================
#  verify
# ==================================================
# Check processes:  
#   ps aux | grep kubectl

# Check listening ports: 
#   netstat -tuln | grep kubectl 
#   ss -tulpn | grep kubectl

# Example expected output:
#   LISTEN 0 128 127.0.0.1:3000
#   LISTEN 0 128 127.0.0.1:3001
#   ...

# Stop all port-forwards:
#   pkill -f "kubectl port-forward"












