# Graph Report - workspace  (2026-09-23)

## Corpus Check
- Corpus is ~26,477 words - fits in a single context window. You may not need a graph.

## Summary
- 186 nodes · 192 edges · 36 communities (13 shown, 23 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 6 edges (avg confidence: 0.75)
- Token cost: 21,000 input · 4,500 output

## Community Hubs (Navigation)
- Python Stdlib Primitives
- Pi Footer Extension
- Dune Sandbox CLI
- Graphify Skill Docs
- Setup and Backup
- Git Config and Hooks
- Neovim Core Config
- Kisski Models Script
- Supernote Transcriber
- Conda and LaTeX OCR
- Blink and LSP
- DAP Debugging
- Treesitter
- Dune Ghola Script
- Kitty Terminal
- Mason Bridge
- Telescope Actions
- Dune Spice Script
- Docker Setup Script
- Rollback Strategy
- Scan Exclusions
- Writing Style Rules

## God Nodes (most connected - your core abstractions)
1. `Neovim config` - 11 edges
2. `render()` - 9 edges
3. `graphify skill` - 9 edges
4. `Dune AI Sandbox` - 7 edges
5. `colorThinkingLabel()` - 6 edges
6. `process_single_note()` - 6 edges
7. `Supernote Transcriber` - 6 edges
8. `Zsh config` - 6 edges
9. `main()` - 5 edges
10. `SSH config` - 5 edges

## Surprising Connections (you probably didn't know these)
- `GitLab read token (env)` --semantically_similar_to--> `GitLab URL rewrite to SSH`  [INFERRED] [semantically similar]
  dune/sandboxes/mentat/docker-compose.yml → git/README.md
- `Zsh config` --conceptually_related_to--> `hpc login host`  [INFERRED]
  zsh/README.md → ssh/README.md
- `graphify skill` --conceptually_related_to--> `Dotfiles - Lorenz Mohr`  [INFERRED]
  dune/sandboxes/mentat/config/pi/agent/skills/graphify/SKILL.md → README.md
- `Automated Backup Directory` --conceptually_related_to--> `Backup Strategy`  [INFERRED]
  backups/README.md → README.md
- `Lazygit config` --conceptually_related_to--> `Git config`  [INFERRED]
  lazygit/README.md → git/README.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Rose Pine theme family** — kitty_readme_rose_pine_theme, tmux_readme_rose_pine_theme, nvim_readme_rose_pine_theme [INFERRED 0.85]
- **Dune sandbox stack** — dune_readme_dune_sandbox, dune_sandboxes_mentat_docker_compose_dune_mentat_service, dune_sandboxes_mentat_config_pi_agent_agents_globel_pi_instructions, tmux_readme_tmuxinator_session [EXTRACTED 1.00]
- **TU Ilmenau infrastructure** — git_readme_gitlab_redirect, ssh_readme_hpc_host, ssh_readme_makalu_proxy_jump, dune_sandboxes_mentat_docker_compose_gitlab_read_token [INFERRED 0.85]

## Communities (36 total, 23 thin omitted)

### Community 0 - "Python Stdlib Primitives"
Cohesion: 0.10
Nodes (27): base64, Path, pathlib, pil, Popen, re, shutil, subprocess (+19 more)

### Community 1 - "Pi Footer Extension"
Cohesion: 0.12
Nodes (23): colorRgb(), colorThinkingLabel(), CONTEXT_COLOR_STOPS, EFFORT_COLOR_STOPS, formatContextWindow(), formatDirectory(), getCurrentDirectory(), getProviderColor() (+15 more)

### Community 2 - "Dune Sandbox CLI"
Cohesion: 0.09
Nodes (20): dune script, dune-mentat script, PYTHON_VERSION, SANDBOX_NAME, TARGET_PROJECT, usage(), dune/agent-latest branch, Dune AI Sandbox (+12 more)

### Community 3 - "Graphify Skill Docs"
Cohesion: 0.17
Nodes (12): graphify reference: add a URL and watch a folder, graphify reference: extra exports and benchmark, graphify reference: extraction subagent prompt, graphify reference: GitHub clone and cross-repo merge, graphify reference: commit hook and native CLAUDE.md integration, graphify reference: query, path, explain, graphify reference: transcribe video and audio, graphify reference: incremental update and cluster-only (+4 more)

### Community 4 - "Setup and Backup"
Cohesion: 0.20
Nodes (10): Automated Backup Directory, Backup Strategy, backup_if_exists(), PATH, setup_full.sh script, GitHub over port 443, hpc login host, llm-tunnel (+2 more)

### Community 5 - "Git Config and Hooks"
Cohesion: 0.18
Nodes (10): GitLab read token (env), pre-push script, Git config, GitLab URL rewrite to SSH, pre-push hook, Lazygit config, Rose Pine theme (tmux), Tmux config (+2 more)

### Community 6 - "Neovim Core Config"
Cohesion: 0.18
Nodes (10): blink.cmp completion, nvim-dap debugging, lazy.nvim, Mason tool manager, Neovim config, OSC 52 clipboard, Rose Pine colorscheme (nvim), Telescope fuzzy finder (+2 more)

### Community 7 - "Kisski Models Script"
Cohesion: 0.33
Nodes (6): generate_enhanced_config(), get_api_key(), Extracts the API key from the ../.env, json, os, requests

### Community 8 - "Supernote Transcriber"
Cohesion: 0.33
Nodes (7): transcriber conda env, Scientific transcription prompt, Ollama, qwen3-vl:8b-instruct vision model, Supernote Transcriber, supernotelib, load_system_prompt()

### Community 9 - "Conda and LaTeX OCR"
Cohesion: 0.40
Nodes (4): miniforge3_etc_profile_d_conda_sh, run_latex-ocr.sh script, LaTeX OCR (macOS), pix2tex

### Community 11 - "DAP Debugging"
Cohesion: 0.50
Nodes (3): dap_python, dapui, nvim_dap_virtual_text

### Community 12 - "Treesitter"
Cohesion: 0.50
Nodes (3): nvim_treesitter_configs, nvim_treesitter_parsers, treesitter_context

### Community 14 - "Kitty Terminal"
Cohesion: 0.67
Nodes (3): Kitty terminal config, JetBrainsMono Nerd Font, Rose Pine theme (kitty)

## Knowledge Gaps
- **47 isolated node(s):** `ThinkingLevel`, `RgbColor`, `ModelWithThinking`, `THINKING_LEVELS`, `EFFORT_COLOR_STOPS` (+42 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 110 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **23 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `duncan tmuxinator session` connect `Git Config and Hooks` to `Dune Sandbox CLI`, `Neovim Core Config`?**
  _High betweenness centrality (0.052) - this node is a cross-community bridge._
- **Why does `Neovim config` connect `Neovim Core Config` to `Setup and Backup`, `Git Config and Hooks`?**
  _High betweenness centrality (0.047) - this node is a cross-community bridge._
- **What connects `ThinkingLevel`, `RgbColor`, `ModelWithThinking` to the rest of the system?**
  _47 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Python Stdlib Primitives` be split into smaller, more focused modules?**
  _Cohesion score 0.10052910052910052 - nodes in this community are weakly interconnected._
- **Should `Pi Footer Extension` be split into smaller, more focused modules?**
  _Cohesion score 0.12307692307692308 - nodes in this community are weakly interconnected._
- **Should `Dune Sandbox CLI` be split into smaller, more focused modules?**
  _Cohesion score 0.09486166007905138 - nodes in this community are weakly interconnected._