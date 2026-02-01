# Shared AI Tools Configuration

This repository contains shared agents, skills, and configurations for **Claude Code** and **Gemini CLI**, synced across multiple repositories using a central repository and a sync script.

## Overview

The `sync.sh` script automates the process of injecting your shared agents and instructions into any target project, configuring them correctly for both Claude and Gemini.

- **Claude Code**: Agents are synced to `.claude/agents/` and shared instructions to `.claude/shared/`.
- **Gemini CLI**: Agents are synced as skills to `.gemini/skills/` and shared instructions to `.gemini/shared/`, with automatic `@reference` injection in `GEMINI.md`.

## Setup and Usage

1. **Clone this repository**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/shared-ai-tools.git ~/dev/shared-ai-tools
   ```

2. **Sync to a project**:
   Run the sync script and provide the path to the project you want to update:
   ```bash
   ~/dev/shared-ai-tools/sync.sh /path/to/your/project
   ```

## Directory Structure

```
shared-ai-tools/
├── agents/                    # Shared agents/skills (synced)
│   ├── strategic-brainstorm-researcher.md
│   ├── git-commit-writer.md
│   └── ...
├── shared/                    # Shared instructions (synced)
│   └── no-flatter-mode.md
├── sync.sh                    # The sync utility script
└── README.md
```

## Daily Workflow

### Update Shared Tools
1. Edit or add files in `agents/` or `shared/` within this repository.
2. Commit and push your changes.
3. Run `./sync.sh <project-path>` on your target projects to pull in the updates.

### Adding New Agents
Simply create a new `.md` file in the `agents/` directory. The next time you run `sync.sh`, it will be available as:
- A Claude agent: `memory/agent-name`
- A Gemini skill: `activate_skill(name="agent-name")`