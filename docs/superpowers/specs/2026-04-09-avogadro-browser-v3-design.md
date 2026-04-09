# Design Document: Avogadro 1.2 Browser V3 (Multi-Target Builds)

## Overview
This update enables automated builds for three distinct targets: CPU (Software), General GPU (Intel/AMD), and NVIDIA GPU. Each target will have its own Dockerfile and will be built and pushed to GitHub Container Registry (GHCR) using GitHub Actions.

## Architecture Changes
- **Targeted Dockerfiles:**
  - `Dockerfile.cpu`: Optimized for software-only rendering (Ubuntu 18.04).
  - `Dockerfile.gpu`: Includes Mesa DRI drivers for Intel/AMD hardware (Ubuntu 18.04).
  - `Dockerfile.nvidia`: Built on top of the `nvidia/opengl` base image for native NVIDIA support (Ubuntu 18.04).
- **CI/CD Orchestration:** A GitHub Actions matrix build will handle the simultaneous building of all three tags.
- **Tagging Strategy:**
  - `ghcr.io/${{ github.repository }}:cpu`
  - `ghcr.io/${{ github.repository }}:gpu`
  - `ghcr.io/${{ github.repository }}:nvidia`

## Component Configuration

### Dockerfile.cpu
- Base: `ubuntu:18.04`
- Packages: Standard dependencies + Mesa (software).

### Dockerfile.gpu
- Base: `ubuntu:18.04`
- Packages: Standard dependencies + `libgl1-mesa-dri`.

### Dockerfile.nvidia
- Base: `nvidia/opengl:1.2-glvnd-runtime-ubuntu18.04`
- Packages: Standard dependencies.

### GitHub Actions Workflow (Updated)
- Uses a `matrix` with `target: [cpu, gpu, nvidia]`.
- Dynamically selects the `Dockerfile` and `tag` based on the matrix.
- Requires `GITHUB_TOKEN` for pushing to GHCR.

## Success Criteria
1. GitHub Actions successfully builds all three images on push to `master`.
2. Three separate tags appear in the GitHub Container Registry.
3. Each image can be pulled and run independently.
4. The `nvidia` tag correctly identifies NVIDIA hardware when the `nvidia` runtime is provided.
