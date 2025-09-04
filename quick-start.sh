#!/bin/bash
echo "🚀 Starting Prometheus Agent System..."

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

# Start MongoDB
echo "Starting MongoDB on port 27018..."
docker-compose up -d mongodb-agents

# Wait for MongoDB to be ready
echo "Waiting for MongoDB to initialize..."
sleep 10

# Run agent initialization
echo "Initializing agents..."
node initialize-agents.js

# Show status
echo ""
echo "═══════════════════════════════════════"
echo "Services Status:"
docker ps --filter "name=seo-agents"
echo ""
echo "MongoDB Connection:"
echo "mongodb://prometheus:agent-system-2025@localhost:27018/?authSource=admin"
echo ""
echo "Dashboard: http://localhost:5000"
echo "═══════════════════════════════════════"
