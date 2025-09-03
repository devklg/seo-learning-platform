#!/bin/bash

# SEO Learning Platform - Agent Dashboard Integration Script
# Prometheus Agent Orchestration System
# This script integrates the agent-workflow-dash with our SEO project

echo "🚀 Initializing Agent Dashboard Integration..."

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: Not in project root directory"
    exit 1
fi

# Clone agent-workflow-dash as a submodule or separate directory
echo "📦 Setting up Agent Workflow Dashboard..."
if [ ! -d "agent-dashboard" ]; then
    git clone https://github.com/devklg/agent-workflow-dash.git agent-dashboard
    echo "✅ Dashboard cloned successfully"
else
    echo "⚠️  Dashboard already exists, pulling latest changes..."
    cd agent-dashboard && git pull && cd ..
fi

# Create environment configuration for dashboard
echo "🔧 Configuring dashboard environment..."
cat > agent-dashboard/server/.env << EOF
# Agent Workflow Dashboard Configuration
NODE_ENV=development
PORT=5000
CLIENT_URL=http://localhost:3000

# MongoDB Configuration
MONGODB_URI=mongodb://localhost:27017/seo-learning-agents

# GitHub Integration
GITHUB_TOKEN=${GITHUB_TOKEN}
GITHUB_REPO=devklg/seo-learning-platform
GITHUB_OWNER=devklg

# ChromaDB Configuration
CHROMADB_HOST=localhost
CHROMADB_PORT=8000
CHROMADB_COLLECTION=seo_learning_platform_dev

# OpenAI Configuration (for AI features)
OPENAI_API_KEY=${OPENAI_API_KEY}

# Agent Configuration
AGENT_COUNT=32
PROJECT_TIMELINE=36_HOURS
CHECK_IN_INTERVAL=20

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# JWT Secret
JWT_SECRET=prometheus-seo-learning-platform-2025

# Email Configuration (optional)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=${EMAIL_USER}
EMAIL_PASS=${EMAIL_PASS}
EOF

echo "✅ Environment configuration created"

# Install dashboard dependencies
echo "📚 Installing dashboard dependencies..."
cd agent-dashboard
npm install --prefix server
npm install --prefix client 2>/dev/null || echo "Client not yet configured"
cd ..

# Create docker-compose override for integration
echo "🐳 Creating Docker integration..."
cat > docker-compose.override.yml << EOF
version: '3.8'

services:
  mongodb:
    image: mongo:latest
    container_name: seo-agents-mongodb
    restart: unless-stopped
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db
      - mongodb_config:/data/configdb
    environment:
      MONGO_INITDB_DATABASE: seo-learning-agents

  chromadb:
    image: chromadb/chroma:latest
    container_name: seo-agents-chromadb
    restart: unless-stopped
    ports:
      - "8000:8000"
    volumes:
      - chromadb_data:/chroma/chroma
    environment:
      IS_PERSISTENT: TRUE
      PERSIST_DIRECTORY: /chroma/chroma

  agent-dashboard:
    build: ./agent-dashboard/server
    container_name: agent-dashboard-server
    restart: unless-stopped
    ports:
      - "5000:5000"
    depends_on:
      - mongodb
      - chromadb
    volumes:
      - ./agent-dashboard/server:/app
      - /app/node_modules
    environment:
      NODE_ENV: development
      MONGODB_URI: mongodb://mongodb:27017/seo-learning-agents
      CHROMADB_HOST: chromadb

volumes:
  mongodb_data:
  mongodb_config:
  chromadb_data:
EOF

echo "✅ Docker integration configured"

# Create agent initialization script
echo "🤖 Creating agent initialization script..."
cat > initialize-agents.js << 'EOF'
const fs = require('fs');
const path = require('path');

// Load configuration
const config = JSON.parse(fs.readFileSync('./agent-orchestration/config.json', 'utf8'));

console.log('🚀 Initializing Agent System...');
console.log(`📊 Total Agents: ${config.teams.atlas.agents.length + config.teams.aurora.agents.length + config.teams.phoenix.agents.length + config.teams.sentinel.agents.length}`);
console.log(`⏱️  Timeline: ${config.project.timeline}`);

// Function to create agent branches
async function createAgentBranches() {
    const { exec } = require('child_process');
    const util = require('util');
    const execPromise = util.promisify(exec);
    
    const allAgents = [
        ...config.teams.atlas.agents,
        ...config.teams.aurora.agents,
        ...config.teams.phoenix.agents,
        ...config.teams.sentinel.agents
    ];
    
    console.log('\n📝 Creating agent branches...');
    for (const agent of allAgents) {
        try {
            await execPromise(`git branch ${agent.branch} 2>/dev/null || true`);
            console.log(`✅ Branch created: ${agent.branch}`);
        } catch (error) {
            console.log(`⚠️  Branch exists: ${agent.branch}`);
        }
    }
    
    console.log('\n✨ All agent branches ready!');
}

// Function to register agents with dashboard
async function registerAgentsWithDashboard() {
    console.log('\n📡 Registering agents with dashboard...');
    // This would connect to the dashboard API to register agents
    // For now, we'll create a registration file
    
    const registration = {
        timestamp: new Date().toISOString(),
        project: config.project,
        agents: [],
        total_tasks: 147
    };
    
    Object.keys(config.teams).forEach(teamName => {
        const team = config.teams[teamName];
        team.agents.forEach(agent => {
            registration.agents.push({
                ...agent,
                team: teamName,
                workspace: `${teamName}_workspace`,
                last_checkin: null,
                tasks_completed: 0,
                current_task: null
            });
        });
    });
    
    fs.writeFileSync('./agent-orchestration/registration.json', JSON.stringify(registration, null, 2));
    console.log('✅ Agent registration complete');
}

// Main initialization
async function initialize() {
    await createAgentBranches();
    await registerAgentsWithDashboard();
    
    console.log('\n' + '='.repeat(50));
    console.log('🎯 PROMETHEUS SYSTEM READY');
    console.log('='.repeat(50));
    console.log('\n📋 Next Steps:');
    console.log('1. Start MongoDB: docker-compose up mongodb');
    console.log('2. Start ChromaDB: docker-compose up chromadb');
    console.log('3. Start Dashboard: cd agent-dashboard/server && npm start');
    console.log('4. Use command: "INITIALIZE ALL AGENTS"');
    console.log('\n🔗 Dashboard URL: http://localhost:5000');
    console.log('📊 Monitoring URL: http://localhost:3000');
}

initialize().catch(console.error);
EOF

echo "✅ Agent initialization script created"

# Create monitoring dashboard HTML
echo "📊 Creating live monitoring dashboard..."
cat > live-dashboard.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Prometheus - SEO Learning Platform Agent Monitor</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Segoe UI', system-ui, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #fff;
            padding: 20px;
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        h1 { font-size: 2.5em; margin-bottom: 10px; }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: rgba(255,255,255,0.1);
            backdrop-filter: blur(10px);
            padding: 20px;
            border-radius: 15px;
            text-align: center;
        }
        .stat-value { font-size: 2em; font-weight: bold; }
        .team-section {
            background: rgba(255,255,255,0.05);
            backdrop-filter: blur(5px);
            padding: 20px;
            border-radius: 15px;
            margin-bottom: 20px;
        }
        .agent-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            gap: 10px;
            margin-top: 15px;
        }
        .agent-card {
            background: rgba(255,255,255,0.1);
            padding: 10px;
            border-radius: 8px;
            text-align: center;
            transition: all 0.3s;
        }
        .agent-card:hover { transform: scale(1.05); }
        .status-active { border-left: 4px solid #00ff00; }
        .status-idle { border-left: 4px solid #ffff00; }
        .status-error { border-left: 4px solid #ff0000; }
        .alert { 
            background: #ff4444;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            display: none;
        }
        .alert.show { display: block; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 Prometheus Agent Monitor</h1>
        <p>SEO Learning Platform - 36 Hour Sprint</p>
        <p id="timer">Time Remaining: 36:00:00</p>
    </div>
    
    <div id="alert" class="alert">
        <strong>⚠️ RED ALERT:</strong> <span id="alertMessage"></span>
    </div>
    
    <div class="stats">
        <div class="stat-card">
            <div class="stat-value">32</div>
            <div>Active Agents</div>
        </div>
        <div class="stat-card">
            <div class="stat-value" id="tasksComplete">0</div>
            <div>Tasks Complete</div>
        </div>
        <div class="stat-card">
            <div class="stat-value">147</div>
            <div>Total Tasks</div>
        </div>
        <div class="stat-card">
            <div class="stat-value" id="progress">0%</div>
            <div>Progress</div>
        </div>
    </div>
    
    <div class="team-section">
        <h2>⚡ Atlas Team - Core Development</h2>
        <div class="agent-grid" id="atlasTeam"></div>
    </div>
    
    <div class="team-section">
        <h2>🌟 Aurora Team - Infrastructure</h2>
        <div class="agent-grid" id="auroraTeam"></div>
    </div>
    
    <div class="team-section">
        <h2>🔥 Phoenix Team - Testing & QA</h2>
        <div class="agent-grid" id="phoenixTeam"></div>
    </div>
    
    <div class="team-section">
        <h2>🛡️ Sentinel Team - Security</h2>
        <div class="agent-grid" id="sentinelTeam"></div>
    </div>
    
    <script>
        // WebSocket connection to dashboard
        let ws;
        let startTime = new Date();
        let endTime = new Date(startTime.getTime() + (36 * 60 * 60 * 1000));
        
        // Timer update
        setInterval(() => {
            const now = new Date();
            const remaining = endTime - now;
            if (remaining > 0) {
                const hours = Math.floor(remaining / (1000 * 60 * 60));
                const minutes = Math.floor((remaining % (1000 * 60 * 60)) / (1000 * 60));
                const seconds = Math.floor((remaining % (1000 * 60)) / 1000);
                document.getElementById('timer').textContent = 
                    `Time Remaining: ${hours}:${minutes.toString().padStart(2,'0')}:${seconds.toString().padStart(2,'0')}`;
            }
        }, 1000);
        
        // Connect to WebSocket
        function connectWebSocket() {
            ws = new WebSocket('ws://localhost:5000');
            
            ws.onopen = () => {
                console.log('Connected to agent dashboard');
            };
            
            ws.onmessage = (event) => {
                const data = JSON.parse(event.data);
                updateDashboard(data);
            };
            
            ws.onerror = (error) => {
                console.error('WebSocket error:', error);
            };
            
            ws.onclose = () => {
                console.log('Disconnected, reconnecting...');
                setTimeout(connectWebSocket, 5000);
            };
        }
        
        // Update dashboard with real-time data
        function updateDashboard(data) {
            if (data.alert) {
                document.getElementById('alert').classList.add('show');
                document.getElementById('alertMessage').textContent = data.alert;
            }
            
            if (data.progress) {
                document.getElementById('progress').textContent = data.progress + '%';
                document.getElementById('tasksComplete').textContent = data.tasksComplete;
            }
        }
        
        // Initialize teams display
        function initializeTeams() {
            const teams = {
                atlas: 10,
                aurora: 10,
                phoenix: 10,
                sentinel: 3
            };
            
            Object.keys(teams).forEach(team => {
                const container = document.getElementById(team + 'Team');
                for (let i = 1; i <= teams[team]; i++) {
                    const card = document.createElement('div');
                    card.className = 'agent-card status-idle';
                    card.id = `${team}-${i}`;
                    card.innerHTML = `
                        <div>${team}-${i}</div>
                        <small>Ready</small>
                    `;
                    container.appendChild(card);
                }
            });
        }
        
        // Initialize on load
        window.onload = () => {
            initializeTeams();
            connectWebSocket();
        };
    </script>
</body>
</html>
EOF

echo "✅ Live monitoring dashboard created"

echo ""
echo "========================================="
echo "✅ AGENT DASHBOARD INTEGRATION COMPLETE"
echo "========================================="
echo ""
echo "📋 Setup Summary:"
echo "  • Dashboard cloned to ./agent-dashboard"
echo "  • Environment configured"
echo "  • Docker services configured"
echo "  • Agent initialization script ready"
echo "  • Live monitoring dashboard created"
echo ""
echo "🚀 To start the system:"
echo "  1. Install dependencies: cd agent-dashboard && npm run setup"
echo "  2. Start services: docker-compose up -d"
echo "  3. Initialize agents: node initialize-agents.js"
echo "  4. Open dashboard: open live-dashboard.html"
echo ""
echo "Ready for: INITIALIZE ALL AGENTS"
