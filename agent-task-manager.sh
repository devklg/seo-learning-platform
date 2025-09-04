#!/bin/bash
# Agent Task Manager for Worktrees
# Manages task distribution and synchronization

echo "📋 Agent Task Distribution System"
echo "================================="

# Configuration
WORKTREE_BASE="./agent-worktrees"
MAIN_BRANCH="prometheus-integration"

# Function to push agent work
push_agent_work() {
    local team=$1
    local agent_id=$2
    local message=$3
    
    local worktree_path="$WORKTREE_BASE/$team/$team-$agent_id"
    
    if [ -d "$worktree_path" ]; then
        cd "$worktree_path"
        git add .
        git commit -m "[$team-$agent_id] $message"
        git push origin "$team-$agent_id"
        cd - > /dev/null
        echo "✅ Pushed: $team-$agent_id"
    else
        echo "❌ Worktree not found: $worktree_path"
    fi
}

# Function to sync agent with main
sync_agent_with_main() {
    local team=$1
    local agent_id=$2
    
    local worktree_path="$WORKTREE_BASE/$team/$team-$agent_id"
    
    if [ -d "$worktree_path" ]; then
        cd "$worktree_path"
        git fetch origin
        git merge "origin/$MAIN_BRANCH" --no-edit
        cd - > /dev/null
        echo "✅ Synced: $team-$agent_id with main"
    else
        echo "❌ Worktree not found: $worktree_path"
    fi
}

# Function to check agent status
check_agent_status() {
    echo ""
    echo "🔍 Checking Agent Status..."
    echo "---------------------------"
    
    for team in atlas aurora phoenix sentinel; do
        echo ""
        echo "Team: $team"
        
        # Get agent count per team
        case $team in
            sentinel) count=3 ;;
            *) count=10 ;;
        esac
        
        for i in $(seq 1 $count); do
            worktree_path="$WORKTREE_BASE/$team/$team-$i"
            if [ -d "$worktree_path" ]; then
                cd "$worktree_path" 2>/dev/null
                
                # Check for uncommitted changes
                if [[ -n $(git status --porcelain) ]]; then
                    echo "  $team-$i: ⚠️  Uncommitted changes"
                else
                    # Check if branch is ahead of origin
                    if [[ -n $(git log origin/$team-$i..$team-$i 2>/dev/null) ]]; then
                        echo "  $team-$i: 📤 Ready to push"
                    else
                        echo "  $team-$i: ✅ Up to date"
                    fi
                fi
                
                cd - > /dev/null 2>&1
            else
                echo "  $team-$i: ❌ No worktree"
            fi
        done
    done
}

# Main menu
case "$1" in
    "setup")
        ./setup-worktrees.sh
        ;;
    "status")
        check_agent_status
        ;;
    "push")
        if [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
            echo "Usage: $0 push [team] [agent_id] [message]"
            echo "Example: $0 push atlas 1 'Completed navbar component'"
        else
            push_agent_work $2 $3 "$4"
        fi
        ;;
    "sync")
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Usage: $0 sync [team] [agent_id]"
            echo "Example: $0 sync aurora 5"
        else
            sync_agent_with_main $2 $3
        fi
        ;;
    "sync-all")
        echo "Syncing all agents with main branch..."
        for team in atlas aurora phoenix sentinel; do
            case $team in
                sentinel) count=3 ;;
                *) count=10 ;;
            esac
            
            for i in $(seq 1 $count); do
                sync_agent_with_main $team $i
            done
        done
        ;;
    *)
        echo "Agent Task Manager - Usage:"
        echo ""
        echo "  $0 setup      - Create all worktrees"
        echo "  $0 status     - Check status of all agents"
        echo "  $0 push [team] [id] [msg] - Push agent work"
        echo "  $0 sync [team] [id]        - Sync agent with main"
        echo "  $0 sync-all   - Sync all agents with main"
        echo ""
        echo "Teams: atlas, aurora, phoenix, sentinel"
        echo "Agent IDs: 1-10 (1-3 for sentinel)"
        ;;
esac

echo ""
