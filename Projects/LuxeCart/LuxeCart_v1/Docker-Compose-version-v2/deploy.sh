#!/bin/bash
set -e

echo "════════════════════════════════════════════════════════════════"
echo "🚀 DEPLOYING LUXECART MICROSERVICES + MONITORING"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "This will:"
echo "  ✅ Deploy all 15 microservices (12 Node.js + 3 Python)"
echo "  ✅ Deploy monitoring stack (Prometheus + Grafana)"
echo "  ✅ Deploy database exporters (PostgreSQL, Redis, MongoDB, Elasticsearch)"
echo "  ✅ Enable /metrics endpoints on all services"
echo "  ✅ Sync Elasticsearch index"
echo ""

# Verify docker-compose context
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ ERROR: Run from ~/DevOps/ecommerce-microservices/"
    exit 1
fi

# Optional: free old build cache (disk cleanup)
echo "🔹 Pruning old BuildKit cache..."
docker buildx prune -af || echo "⚠️  BuildKit cache prune failed, continuing..."

echo ""
echo "Step 1: Rebuilding services sequentially (memory-safe)..."

SERVICES=(
  analytics-service
  recommendation-service
  email-service
  auth-service
  user-service
  product-service
  cart-service
  order-service
  review-service
  rating-service
  payment-service
  notification-service
  admin-service
  inventory-service
  search-service
  api-gateway
  frontend
)

for svc in "${SERVICES[@]}"; do
    echo "▶ Building service: $svc"
    docker-compose build --no-cache "$svc"
done

echo ""
echo "Step 2: Starting all services..."
docker-compose up -d 

echo ""
echo "Step 3: Waiting 60 seconds for services to initialize..."
for i in {60..1}; do
    printf "\r  ⏳ %02d seconds remaining..." $i
    sleep 1
done
echo ""

echo ""
echo "Step 4: Syncing Elasticsearch index..."
SYNC_RESULT=$(curl -s -X POST http://localhost:3000/api/search/index/sync 2>/dev/null || echo "")
if echo "$SYNC_RESULT" | grep -q "Synced"; then
    PRODUCT_COUNT=$(echo "$SYNC_RESULT" | grep -o '"count":[0-9]*' | grep -o '[0-9]*')
    echo "  ✅ Elasticsearch: Synced $PRODUCT_COUNT products"
else
    echo "  ⚠️  Elasticsearch: Still initializing — try manually:"
    echo "     curl -X POST http://localhost:3000/api/search/index/sync"
fi

echo ""
echo "Step 5: Verifying core services..."

# Check Python services
ANALYTICS=$(curl -s http://localhost:3013/health 2>/dev/null | grep -o "healthy" || echo "")
RECO=$(curl -s http://localhost:3014/health 2>/dev/null | grep -o "healthy" || echo "")
EMAIL=$(curl -s http://localhost:3015/health 2>/dev/null | grep -o "healthy" || echo "")

[ "$ANALYTICS" = "healthy" ] && echo "  ✅ Analytics Service" || echo "  ⚠️  Analytics Service"
[ "$RECO" = "healthy" ] && echo "  ✅ Recommendation Service" || echo "  ⚠️  Recommendation Service"
[ "$EMAIL" = "healthy" ] && echo "  ✅ Email Service" || echo "  ⚠️  Email Service"

echo ""
echo "Step 6: Verifying monitoring stack..."

# Prometheus health
PROM_STATUS=$(curl -s http://localhost:9090/-/healthy 2>/dev/null || echo "")
if [ "$PROM_STATUS" = "Prometheus Server is Healthy." ]; then
    echo "  ✅ Prometheus: Running"
else
    echo "  ⚠️  Prometheus: Starting up..."
fi

# Grafana health
GRAFANA_STATUS=$(curl -s http://localhost:3100/api/health 2>/dev/null | grep -o "ok" || echo "")
if [ "$GRAFANA_STATUS" = "ok" ]; then
    echo "  ✅ Grafana: Running"
else
    echo "  ⚠️  Grafana: Starting up..."
fi

# Check Prometheus targets
echo ""
echo "Step 7: Checking Prometheus targets..."
sleep 5
TARGETS=$(curl -s http://localhost:9090/api/v1/targets 2>/dev/null | grep -o '"health":"up"' | wc -l || echo "0")
echo "  📊 Prometheus targets UP: $TARGETS"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "✅ DEPLOYMENT COMPLETE"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "🌐 ACCESS POINTS:"
echo ""
echo "  Frontend:        http://localhost"
echo "  API Gateway:     http://localhost:3000"
echo "  Prometheus:      http://localhost:9090"
echo "  Grafana:         http://localhost:3100 (admin/admin)"
echo "  RabbitMQ:        http://localhost:15672 (ecommerce/ecommerce123)"
echo "  Kibana:          http://localhost:5601"
echo ""
echo "📊 MONITORING ENDPOINTS:"
echo ""
echo "  Prometheus Targets:  http://localhost:9090/targets"
echo "  Grafana Dashboards:  http://localhost:3100/dashboards"
echo "  Service Metrics:     http://localhost:<port>/metrics"
echo ""
echo "  Database Exporters:"
echo "    PostgreSQL:      http://localhost:9187/metrics"
echo "    Redis:           http://localhost:9121/metrics"
echo "    MongoDB:         http://localhost:9216/metrics"
echo "    Elasticsearch:   http://localhost:9114/metrics"
echo "    RabbitMQ:        http://localhost:15692/metrics"
echo ""
echo "🔍 QUICK TESTS:"
echo ""
echo "# Test search"
echo "curl 'http://localhost:3000/api/search?q=wireless'"
echo ""
echo "# Test recommendations"
echo "curl 'http://localhost:3000/api/recommendations/trending?days=7'"
echo ""
echo "# Test analytics (requires admin token)"
echo "TOKEN=\$(curl -s -X POST http://localhost:3000/api/auth/login \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"email\":\"admin@ecommerce.com\",\"password\":\"123456\"}' \\"
echo "  | jq -r '.token')"
echo "curl http://localhost:3000/api/analytics/dashboard -H \"Authorization: Bearer \$TOKEN\""
echo ""
echo "# Check Prometheus targets"
echo "curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | select(.health==\"up\") | .labels.job'"
echo ""
echo "📖 FULL DOCUMENTATION: See README.md"
echo ""
