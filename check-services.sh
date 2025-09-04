#!/bin/bash
echo "🔍 Checking Service Status..."
echo "═══════════════════════════════════════════════"

# Function to check if port is open
check_port() {
    local host=$1
    local port=$2
    local service=$3
    
    timeout 1 bash -c "cat < /dev/null > /dev/tcp/$host/$port" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ $service (port $port) - RUNNING"
    else
        echo "❌ $service (port $port) - NOT RUNNING"
    fi
}

echo ""
echo "📦 Docker Services:"
echo "-------------------"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(seo-|NAMES)"

echo ""
echo "🔌 Port Status:"
echo "---------------"
check_port localhost 27018 "MongoDB"
check_port localhost 6379 "Redis"
check_port localhost 5672 "RabbitMQ"
check_port localhost 15672 "RabbitMQ Management"
check_port localhost 5000 "Agent Dashboard"
check_port localhost 8000 "ChromaDB (Local)"

echo ""
echo "📊 Service URLs:"
echo "----------------"
echo "MongoDB:           mongodb://prometheus:agent-system-2025@localhost:27018/?authSource=admin"
echo "Redis:             redis://localhost:6379"
echo "RabbitMQ:          amqp://prometheus:agent-queue-2025@localhost:5672"
echo "RabbitMQ UI:       http://localhost:15672 (user: prometheus)"
echo "Agent Dashboard:   http://localhost:5000"
echo "ChromaDB:          http://localhost:8000"

echo ""
echo "🎯 Quick Commands:"
echo "------------------"
echo "Start all:     docker-compose up -d"
echo "Stop all:      docker-compose down"
echo "View logs:     docker-compose logs -f"
echo "MongoDB shell: docker exec -it seo-agents-mongodb mongosh -u prometheus -p agent-system-2025"
echo "Redis CLI:     docker exec -it seo-redis redis-cli"
echo ""
