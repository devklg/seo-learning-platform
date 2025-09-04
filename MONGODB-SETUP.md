# MongoDB Setup for Agent System

## Connection Details for MongoDB Compass

### Quick Connection String:
```
mongodb://prometheus:agent-system-2025@localhost:27018/?authSource=admin
```

### Manual Connection Settings:
- **Host**: localhost
- **Port**: 27018 (not 27017!)
- **Authentication**: Username/Password
- **Username**: prometheus
- **Password**: agent-system-2025
- **Authentication Database**: admin
- **Database Name**: seo-learning-agents

## Why Docker MongoDB?

1. **Port 27018**: Avoids conflict with any local MongoDB (which uses 27017)
2. **Isolated Data**: Agent data stays separate from other projects
3. **Easy Reset**: Can wipe and restart quickly
4. **Persistent**: Data saved in Docker volumes
5. **Team Friendly**: Same setup for all developers

## Docker Commands:

### Start MongoDB:
```bash
docker-compose up -d mongodb-agents
```

### Stop MongoDB:
```bash
docker-compose stop mongodb-agents
```

### View MongoDB Logs:
```bash
docker-compose logs mongodb-agents
```

### Reset MongoDB (WARNING: Deletes all data):
```bash
docker-compose down -v
docker-compose up -d mongodb-agents
```

## Collections Created:

The agent system will create these collections:
- `agents` - All 32 agent profiles
- `tasks` - 147 tasks to be completed
- `messages` - Agent communication logs
- `checkins` - 20-minute check-in records
- `alerts` - RED/YELLOW/GREEN status alerts
- `github_activity` - Branch commits and PRs
- `progress` - Real-time progress tracking

## MongoDB Compass Views:

After connecting, you can:
1. Watch real-time agent activity
2. Query task completion status
3. Monitor communication patterns
4. Track GitHub integration
5. Analyze performance metrics
