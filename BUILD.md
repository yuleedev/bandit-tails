# Building Mole Heist

This guide explains how to build Mole Heist for different platforms.

## Prerequisites

1. **Godot 4.4+** - Download from [godotengine.org](https://godotengine.org/download)
2. **Export Templates** - Required for building

## Installing Export Templates

### Method 1: Via Godot Editor (Recommended)

1. Open the project in Godot Editor
2. Go to **Editor → Manage Export Templates**
3. Click **Download and Install**
4. Wait for download to complete

### Method 2: Manual Download

1. Download templates from: https://godotengine.org/download/4.x/
2. Extract to:
   - **macOS:** `~/Library/Application Support/Godot/export_templates/4.4.1.stable/`
   - **Windows:** `%APPDATA%\Godot\export_templates\4.4.1.stable\`
   - **Linux:** `~/.local/share/godot/export_templates/4.4.1.stable/`

## Building from Command Line

### macOS Build

```bash
# Using Godot CLI
godot --headless --export-release "macOS" builds/macos/MoleHeist.zip

# Or use the build script
./build.sh macos
```

**Output:** `builds/macos/MoleHeist.zip`

### Windows Build

```bash
# Using Godot CLI
godot --headless --export-release "Windows Desktop" builds/windows/MoleHeist.exe

# Or use the build script
./build.sh windows
```

**Output:** `builds/windows/MoleHeist.exe`

### Linux Build

```bash
# Using Godot CLI
godot --headless --export-release "Linux" builds/linux/MoleHeist.x86_64

# Or use the build script
./build.sh linux
```

**Output:** `builds/linux/MoleHeist.x86_64`

### Build All Platforms

```bash
./build.sh all
```

## Building from Godot Editor

1. Open the project in Godot
2. Go to **Project → Export**
3. Select a preset (macOS, Windows Desktop, or Linux)
4. Click **Export Project**
5. Choose output location
6. Click **Save**

## Build Configuration

Export presets are configured in `export_presets.cfg`:

- **macOS:** Universal binary (Intel + Apple Silicon)
- **Windows:** x86_64 executable
- **Linux:** x86_64 binary

### Key Settings

- **Bundle Identifier (macOS):** `com.moleheist.game`
- **Product Name:** Mole Heist
- **Company Name:** Mole Heist Team
- **Texture Compression:** ETC2 ASTC enabled for mobile/arm64 support

## Build Directory Structure

```
builds/
├── macos/
│   └── MoleHeist.zip (contains .app bundle)
├── windows/
│   ├── MoleHeist.exe
│   └── MoleHeist.pck (embedded by default)
└── linux/
    ├── MoleHeist.x86_64
    └── MoleHeist.pck (embedded by default)
```

## Distribution

### macOS

1. Extract `MoleHeist.zip`
2. Distribute `MoleHeist.app`
3. **Note:** For distribution, you may need to:
   - Code sign the app
   - Notarize with Apple
   - Create a DMG installer

### Windows

1. Distribute `MoleHeist.exe`
2. **Optional:** Create installer with NSIS or Inno Setup
3. **Note:** Consider Windows Defender SmartScreen warnings

### Linux

1. Distribute `MoleHeist.x86_64`
2. **Optional:** Create AppImage or Flatpak
3. Make executable: `chmod +x MoleHeist.x86_64`

## Troubleshooting

### "No export template found"

**Solution:** Install export templates (see above)

### "Cannot export for universal or arm64"

**Solution:** Enable ETC2 ASTC in project settings (already configured in `project.godot`)

### "Godot command not found"

**Solution:** Add Godot to PATH or use full path:
```bash
# macOS
/Applications/Godot.app/Contents/MacOS/Godot --headless --export-release "macOS" builds/macos/MoleHeist.zip
```

### Build fails silently

**Solution:** Check console output:
```bash
godot --headless --export-release "macOS" builds/macos/MoleHeist.zip 2>&1 | tee build.log
```

## Code Signing (macOS)

For proper macOS distribution:

```bash
# Sign the app
codesign --force --deep --sign "Developer ID Application: Your Name" builds/macos/MoleHeist.app

# Verify signature
codesign --verify --verbose builds/macos/MoleHeist.app

# Notarize (requires Apple Developer account)
xcrun notarytool submit builds/macos/MoleHeist.zip \
  --apple-id "your@email.com" \
  --team-id "TEAM_ID" \
  --password "app-specific-password"
```

## Continuous Integration

### GitHub Actions Example

```yaml
name: Build Game

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install Godot
        run: |
          wget https://github.com/godotengine/godot/releases/download/4.4.1-stable/Godot_v4.4.1-stable_linux.x86_64.zip
          unzip Godot_v4.4.1-stable_linux.x86_64.zip

      - name: Install Export Templates
        run: |
          mkdir -p ~/.local/share/godot/export_templates/4.4.1.stable
          wget https://github.com/godotengine/godot/releases/download/4.4.1-stable/Godot_v4.4.1-stable_export_templates.tpz
          unzip Godot_v4.4.1-stable_export_templates.tpz -d ~/.local/share/godot/export_templates/4.4.1.stable/

      - name: Build All Platforms
        run: ./build.sh all

      - name: Upload Artifacts
        uses: actions/upload-artifact@v3
        with:
          name: game-builds
          path: builds/
```

## Build Script

Use the included `build.sh` script for convenient building:

```bash
# Build specific platform
./build.sh macos
./build.sh windows
./build.sh linux

# Build all platforms
./build.sh all

# Clean builds
./build.sh clean
```

## Testing Builds

### macOS
```bash
# Extract and run
unzip builds/macos/MoleHeist.zip
open MoleHeist.app
```

### Windows
```bash
# Run directly
wine builds/windows/MoleHeist.exe  # On Linux/macOS with Wine
# Or test on Windows machine
```

### Linux
```bash
# Make executable and run
chmod +x builds/linux/MoleHeist.x86_64
./builds/linux/MoleHeist.x86_64
```

## Optimization

### Reduce Build Size

1. **Exclude unnecessary files:**
   - Edit export presets filter
   - Add `*.md` to exclude list
   - Add `tests/*` to exclude list

2. **Optimize textures:**
   - Use VRAM compression
   - Reduce texture resolution if needed

3. **Strip debug symbols** (production builds)
   - Use `--export-release` flag

### Current Build Sizes (Approximate)

- **macOS:** ~60-80 MB (universal binary)
- **Windows:** ~50-70 MB
- **Linux:** ~50-70 MB

## Release Checklist

Before releasing a build:

- [ ] All tests pass (`./tests/run_tests.sh`)
- [ ] Version number updated in export presets
- [ ] CHANGELOG.md updated
- [ ] Tested on target platform
- [ ] Code signed (macOS/Windows)
- [ ] README included with build
- [ ] Controls/instructions included

## Support

For build issues:
1. Check Godot export documentation
2. Verify export templates are installed
3. Check console output for errors
4. Test export from Godot Editor first

## References

- [Godot Export Documentation](https://docs.godotengine.org/en/stable/tutorials/export/index.html)
- [Godot Command Line](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html)
- [macOS Codesigning](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_macos.html)
