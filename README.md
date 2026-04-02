
# Blitz3D Build Action

Reusable GitHub Action for compiling Blitz3D projects.

## Usage

```yaml
- uses: yourname/blitz3d-build-action@v1
  with:
    source: src/main.bb
    output: build/game.exe
    include_runtime: true
    media_dir: media