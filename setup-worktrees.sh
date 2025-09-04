#!/bin/bash
# Git Worktree Setup for 32 Agents
# Creates separate working directories for each agent branch

echo "🌳 Setting up Git Worktrees for 32 Agents..."
echo "================================================"

# Base directory for worktrees
WORKTREE_BASE="./agent-worktrees"

# Create base directory
mkdir -p $WORKTREE_BASE

# Function to create worktree for a team
create_team_worktrees() {
    local team=$1
    local count=$2
    local color=$3
    
    echo ""
    echo "$color Creating $team Team Worktrees..."
    echo "-----------------------------------"
    
    for i in $(seq 1 $count); do
        branch_name="$team-$i"
        worktree_path="$WORKTREE_BASE/$team/$branch_name"
        
        # Create team directory
        mkdir -p "$WORKTREE_BASE/$team"
        
        # Check if branch exists, create if not
        if ! git branch --list | grep -q "$branch_name"; then
            echo "  Creating branch: $branch_name"
            git branch "$branch_name" 2>/dev/null || echo "  Branch exists: $branch_name"
        fi
        
        # Create worktree if it doesn't exist
        if [ ! -d "$worktree_path" ]; then
            echo "  ✓ Creating worktree: $worktree_path"
            git worktree add "$worktree_path" "$branch_name" 2>/dev/null || echo "  Worktree exists"
        else
            echo "  ⚠ Worktree exists: $worktree_path"
        fi
    done
}

# Create worktrees for each team
create_team_worktrees "atlas" 10 "🔵"
create_team_worktrees "aurora" 10 "🟣"
create_team_worktrees "phoenix" 10 "🔴"
create_team_worktrees "sentinel" 3 "🟢"

echo ""
echo "================================================"
echo "✅ WORKTREE SETUP COMPLETE!"
echo "================================================"
echo ""
echo "📁 Structure Created:"
echo "agent-worktrees/"
echo "├── atlas/      (10 frontend agents)"
echo "├── aurora/     (10 backend agents)"
echo "├── phoenix/    (10 testing agents)"
echo "└── sentinel/   (3 security agents)"
echo ""
echo "Each agent can now work independently in their own directory!"
echo ""
echo "🔧 Useful Commands:"
echo "-------------------"
echo "List all worktrees:        git worktree list"
echo "Remove a worktree:         git worktree remove [path]"
echo "Prune old worktrees:       git worktree prune"
echo ""
echo "📍 Agent Working Directories:"
echo "-----------------------------"
echo "Example: agent-worktrees/atlas/atlas-1/"
echo "         agent-worktrees/aurora/aurora-5/"
echo "         agent-worktrees/phoenix/phoenix-3/"
echo ""
