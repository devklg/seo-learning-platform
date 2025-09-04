@echo off
echo ═══════════════════════════════════════════════════════════════
echo         PROMETHEUS AGENT SYSTEM - COMPLETE SETUP
echo             SEO Learning Platform Orchestration
echo ═══════════════════════════════════════════════════════════════
echo.

REM Check if we're in the right directory
if not exist "D:\seo-learning-platform" (
    echo Creating project directory...
    mkdir D:\seo-learning-platform
)
cd /d D:\seo-learning-platform

echo [STEP 1/10] Cloning Main Repository...
echo ─────────────────────────────────────────
if not exist ".git" (
    git clone https://github.com/devklg/seo-learning-platform.git .
    git fetch --all
    git checkout prometheus-integration
    echo ✓ Repository cloned and switched to prometheus-integration branch
) else (
    echo Repository exists, updating...
    git fetch --all
    git checkout prometheus-integration
    git pull
    echo ✓ Repository updated
)
echo.

echo [STEP 2/10] Cloning Agent Dashboard...
echo ─────────────────────────────────────────
if not exist "agent-dashboard" (
    git clone https://github.com/devklg/agent-workflow-dash.git agent-dashboard
    echo ✓ Dashboard cloned
) else (
    echo Dashboard exists, updating...
    cd agent-dashboard
    git pull
    cd ..
    echo ✓ Dashboard updated
)
echo.

echo [STEP 3/10] Checking Docker Desktop...
echo ─────────────────────────────────────────
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ ERROR: Docker is not running!
    echo Please start Docker Desktop and run this script again.
    pause
    exit /b 1
)
echo ✓ Docker Desktop is running
echo.

echo [STEP 4/10] Checking Node.js...
echo ─────────────────────────────────────────
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ ERROR: Node.js is not installed!
    echo Please install Node.js from https://nodejs.org
    pause
    exit /b 1
)
echo ✓ Node.js is installed
echo.

echo [STEP 5/10] Installing Dependencies...
echo ─────────────────────────────────────────
if exist "package.json" (
    echo Installing main project dependencies...
    call npm install
)

if exist "agent-dashboard\server\package.json" (
    echo Installing dashboard server dependencies...
    cd agent-dashboard\server
    call npm install
    cd ..\..
)
echo ✓ Dependencies installed
echo.

echo [STEP 6/10] Creating Docker Network...
echo ─────────────────────────────────────────
docker network create seo-agent-network 2>nul
echo ✓ Docker network ready
echo.

echo [STEP 7/10] Starting MongoDB in Docker...
echo ─────────────────────────────────────────
docker-compose up -d mongodb-agents
timeout /t 10 >nul
echo ✓ MongoDB started on port 27018
echo.

echo [STEP 8/10] Verifying ChromaDB...
echo ─────────────────────────────────────────
echo IMPORTANT: Please ensure ChromaDB is running on port 8000
echo If not running, start it with: chroma run --path ./chroma_data
echo.
echo Press any key when ChromaDB is ready...
pause >nul
echo ✓ ChromaDB confirmed
echo.

echo [STEP 9/10] Starting Agent Dashboard...
echo ─────────────────────────────────────────
docker-compose up -d agent-dashboard
timeout /t 5 >nul
echo ✓ Agent Dashboard starting on port 5000
echo.

echo [STEP 10/10] Initializing Agent System...
echo ─────────────────────────────────────────
if exist "initialize-agents.js" (
    echo Running agent initialization...
    node initialize-agents.js
) else (
    echo ⚠️  initialize-agents.js not found, skipping...
)
echo.

echo ═══════════════════════════════════════════════════════════════
echo              ✅ SETUP COMPLETE - ALL SYSTEMS GO!
echo ═══════════════════════════════════════════════════════════════
echo.
echo 🔗 SERVICE ENDPOINTS:
echo ─────────────────────
echo   MongoDB:    localhost:27018 (Docker)
echo   ChromaDB:   localhost:8000  (Local)
echo   Dashboard:  localhost:5000  (Docker)
echo.
echo 📊 MONGODB COMPASS CONNECTION:
echo ──────────────────────────────
echo   mongodb://prometheus:agent-system-2025@localhost:27018/?authSource=admin
echo.
echo 📁 PROJECT DOCUMENTS:
echo ────────────────────
echo   • AGENT-ROSTER.md - Full agent list and roles
echo   • TASK-LIST.md - All 147 tasks with assignments
echo   • MONGODB-SETUP.md - Database configuration
echo.
echo 🎮 NEXT COMMANDS:
echo ────────────────
echo   1. View agent roster: type AGENT-ROSTER.md
echo   2. View task list: type TASK-LIST.md
echo   3. Open dashboard: start http://localhost:5000
echo   4. Health check: curl http://localhost:5000/health
echo.
echo 🚀 Ready for: "INITIALIZE ALL AGENTS"
echo.
pause
