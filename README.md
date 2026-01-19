# Shared .claude Configuration

This directory contains Claude Code agents and shared configurations that are synced across multiple repositories using a central GitHub repository.

## Overview

Each project's `.claude` directory is an independent git repo that pushes/pulls to a central GitHub repository, enabling synchronization of agents and settings across all your projects.

```
GitHub Repo (private/shared-ai-tools)
       ^
       | push/pull
       v
project-a/.claude/
project-b/.claude/
```

## Initial Setup (One Time)

1. **Create a Repository**: Create a repository on GitHub (e.g., `shared-ai-tools`).

2. **Initialize Your First .claude Directory**:

   ```bash
   cd /path/to/your/project/.claude
   git init
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/shared-ai-tools.git

   # Ignore repo-specific files
   echo "settings.local.json" > .gitignore

   # Initial commit and push
   git add agents/ shared/ .gitignore
   git commit -m "Initial shared .claude config"
   git push -u origin main
   ```

3. **Tell Parent Repo to Ignore .claude**:

   Since `.claude` is its own git repo, the parent project must ignore it:

   ```bash
   cd /path/to/your/project
   echo ".claude/" >> .gitignore
   git add .gitignore
   git commit -m "Ignore .claude directory (managed via submodule/repo)"
   ```

## Adding to New Projects

To use your shared configuration in a new project:

1. **Clone the Config**:

   ```bash
   cd /path/to/new/project
   git clone https://github.com/YOUR_USERNAME/shared-ai-tools.git .claude
   ```

2. **Add Local Settings** (Optional/Not Synced):

   ```bash
   cat > .claude/settings.local.json << 'EOF'
   {
     "permissions": {
       "allow": []
     }
   }
   EOF
   ```

3. **Ignore in Parent**:

   ```bash
   echo ".claude/" >> .gitignore
   ```

## Daily Workflow

### Save Changes (from any project)

```bash
cd .claude
git add .
git commit -m "Add/update agent X"
git push
```

### Get Latest Changes

```bash
cd .claude
git pull
```

## Repo-Specific Agents

To create agents that stay local to one repo (not synced to GitHub):

1. **Configure .gitignore**:
   ```bash
   cd .claude
   echo "agents/local-*.md" >> .gitignore
   git add .gitignore
   git commit -m "Allow local-only agents"
   git push
   ```

2. **Create Local Agent**:
   Create files with the ignored prefix:
   `touch agents/local-my-project-agent.md`

## Directory Structure

```
.claude/
├── agents/                    # Shared agents (synced)
│   ├── strategic-brainstorm-researcher.md
│   ├── git-commit-writer.md
│   └── ...
├── shared/                    # Shared resources (synced)
│   └── no-flatter-mode.md
├── settings.local.json        # Repo-specific (ignored)
├── .gitignore
└── README.md
```