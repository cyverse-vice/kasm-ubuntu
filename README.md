[![Project Supported by CyVerse](https://de.cyverse.org/Powered-By-CyVerse-blue.svg)](https://learning.cyverse.org/projects/vice/en/latest/) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) [![license](https://img.shields.io/badge/license-GPLv3-blue.svg)](https://opensource.org/licenses/GPL-3.0)

# KASM Ubuntu

Ubuntu desktop environments running [KASM VNC](https://kasmweb.com/) for full graphical desktop access in the [CyVerse Discovery Environment](https://learning.cyverse.org/vice/about/).

[![Harbor Build Status](https://github.com/cyverse-vice/kasm-ubuntu/actions/workflows/harbor.yml/badge.svg)](https://github.com/cyverse-vice/kasm-ubuntu/actions) ![GitHub commits since tagged version](https://img.shields.io/github/commits-since/cyverse-vice/kasm-ubuntu/latest/main?style=flat-square)

## Quick Launch

| Version | Launch |
|---------|--------|
| 24.04 | <a href="https://de.cyverse.org/apps/de/4bff2982-7b8c-11f0-a538-008cfa5ae621/launch" target="_blank" rel="noopener noreferrer"><img src="https://img.shields.io/badge/KASM-24.04-purple?style=plastic&logo=ubuntu"></a> |

## Features

### AI Development Tools (24.04)
- **Claude Code** - Anthropic AI coding assistant (`claude`)
- **Gemini CLI** - Google AI CLI (`gemini`)
- **OpenAI Codex** - OpenAI coding assistant (`codex`)
- **Node.js 20.x** - JavaScript runtime for AI tools

### Development Tools (24.04)
- **GitHub CLI (`gh`)** - Command-line tool for GitHub operations
- **Go** - Go programming language

### CyVerse Integration
- **GoCommands (`gocmd`)** - CyVerse data transfer utilities
- **iRODS integration** - Direct access to CyVerse Data Store

### Desktop Environment
- **GNOME Desktop** - Full graphical desktop environment
- **KASM VNC** - Browser-based remote desktop (port 6901)

## Quick Start

```bash
# Run Ubuntu 24.04 desktop
docker run -it --rm -p 6901:6901 harbor.cyverse.org/vice/kasm/ubuntu:latest
```

Access the desktop at: http://localhost:6901

### With GPU Support

```bash
docker run -it --rm --gpus all -p 6901:6901 harbor.cyverse.org/vice/kasm/ubuntu:24.04-gpu
```

## Available Images

### Base Ubuntu Desktops

| Image | Description | Command |
|-------|-------------|---------|
| 24.04 | Ubuntu 24.04 with AI tools | `docker run -it --rm -p 6901:6901 harbor.cyverse.org/vice/kasm/ubuntu:latest` |
| 24.04-gpu | Ubuntu 24.04 with GPU | `docker run -it --rm --gpus all -p 6901:6901 harbor.cyverse.org/vice/kasm/ubuntu:24.04-gpu` |
| 22.04 | Ubuntu 22.04 base | `docker run -it --rm -p 6901:6901 harbor.cyverse.org/vice/kasm/ubuntu:22.04` |
| 20.04-gpu | Ubuntu 20.04 with GPU | `docker run -it --rm --gpus all -p 6901:6901 harbor.cyverse.org/vice/kasm/ubuntu:22.04-gpu` |

### Specialized Applications

| Application | Description | Command |
|-------------|-------------|---------|
| **CellProfiler** | Cell image analysis | `docker run -it --rm -p 6901:6901 --gpus all harbor.cyverse.org/vice/kasm/cellprofiler:22.04-4.2.8-gpu` |
| **DeepLabCut** | Animal pose estimation | `docker run -it --rm --gpus all -p 6901:6901 harbor.cyverse.org/vice/kasm/deeplabcut:gpu-2412` |
| **DuckDB** | Analytical database | See [duckdb directory](./duckdb) |
| **iLand** | Forest landscape simulation | See [iland directory](./iland) |
| **ImageJ** | Image processing | See [ImageJ-22.04 directory](./ImageJ-22.04) |
| **Label Studio** | Data labeling platform | `docker run -it --rm -p 6901:6901 harbor.cyverse.org/vice/kasm/labelstudio:1.15.0-noSSL-startup` |
| **Label Studio ML** | Label Studio with ML backend | `docker run -it --rm --gpus all -p 6901:6901 harbor.cyverse.org/vice/kasm/labelstudio:1.15.0-noSSL-ML` |
| **Orange** | Visual data mining | `docker run -it --rm -p 6901:6901 harbor.cyverse.org/vice/kasm/orange:3.38.0` |
| **PyTorch Wildlife** | Wildlife detection | `docker run -it --rm -p 6901:6901 --gpus all harbor.cyverse.org/vice/kasm/pytorch-wildlife:1.2.0` |
| **QGIS** | Geographic information system | See [qgis-22.04 directory](./qgis-22.04) |

## Application Usage

### CellProfiler
```bash
# After container starts, open terminal and run:
cellprofiler
```

### DeepLabCut
```bash
# After container starts, open terminal and run:
conda activate DEEPLABCUT
python -m deeplabcut
```

### Label Studio
Label Studio opens automatically when the container starts.

### Orange
Orange opens automatically when the container starts.

## Build Your Own Container

```dockerfile
FROM harbor.cyverse.org/vice/kasm/ubuntu:latest

# Add your customizations
USER root
RUN apt-get update && apt-get install -y your-package

USER kasm-user
```

## Resources

- [CyVerse VICE Documentation](https://learning.cyverse.org/vice/about/)
- [Integrate Your Own Tools](https://learning.cyverse.org/de/create_apps/)
- [KASM Documentation](https://kasmweb.com/docs/)
- [GoCommands Documentation](https://learning.cyverse.org/ds/gocommands/)
