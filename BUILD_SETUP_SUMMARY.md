# Build Setup Summary

## What Was Configured

The Mole Heist project is now fully configured for building on macOS, Windows, and Linux platforms.

## Files Created

### 1. Export Configuration
- **`export_presets.cfg`** - Export settings for all three platforms
  - macOS: Universal binary (Intel + Apple Silicon)
  - Windows: x86_64 executable
  - Linux: x86_64 binary

### 2. Build Automation
- **`build.sh`** - Automated build script with color-coded output
  - Detects Godot installation
  - Checks for export templates
  - Builds for one or all platforms
  - Shows build sizes
  - Clean command

### 3. Documentation
- **`BUILD.md`** - Comprehensive build guide
  - Prerequisites
  - Export template installation
  - Command-line build instructions
  - Godot Editor build instructions
  - Distribution guidelines
  - Code signing information
  - CI/CD examples
  - Troubleshooting

### 4. Project Configuration
- **`project.godot`** - Updated with rendering settings
  - Added ETC2 ASTC texture compression (required for arm64/mobile)

### 5. Git Configuration
- **`.gitignore`** - Updated to exclude build artifacts
  - `builds/` directory
  - `*.log` files

### 6. CLAUDE.md Update
- Added building commands section
- Quick reference for developers

## How to Build

### Quick Start (After Installing Export Templates)

```bash
# Build all platforms
./build.sh all
```

### Platform-Specific Builds

```bash
# macOS only
./build.sh macos

# Windows only
./build.sh windows

# Linux only
./build.sh linux
```

### Output Locations

```
builds/
├── macos/
│   └── MoleHeist.zip         (~60-80 MB)
├── windows/
│   └── MoleHeist.exe         (~50-70 MB)
└── linux/
    └── MoleHeist.x86_64      (~50-70 MB)
```

## Prerequisites

### 1. Godot Installation

The project requires **Godot 4.4+**. The build script will automatically detect:
- `godot` command in PATH
- `godot4` command in PATH
- `/Applications/Godot.app/Contents/MacOS/Godot` (macOS default)
- `/usr/local/bin/godot`

### 2. Export Templates

**Required for building!** Install via:

#### Option A: Godot Editor (Recommended)
1. Open project in Godot
2. Editor → Manage Export Templates
3. Download and Install

#### Option B: Manual Download
1. Download from: https://godotengine.org/download/4.x/
2. Extract to platform-specific location (see BUILD.md)

## Build Script Features

### Color-Coded Output
- 🔵 Blue: Info messages
- 🟢 Green: Success messages
- 🟡 Yellow: Warnings
- 🔴 Red: Errors

### Automatic Checks
- ✅ Godot executable detection
- ✅ Export templates verification
- ✅ Build directory creation
- ✅ File permission setting (Linux)
- ✅ Build size reporting

### Commands

```bash
./build.sh macos      # Build macOS only
./build.sh windows    # Build Windows only
./build.sh linux      # Build Linux only
./build.sh all        # Build all platforms
./build.sh clean      # Remove builds/ directory
```

## Export Preset Details

### macOS
- **Format:** .app bundle in .zip
- **Architecture:** Universal (Intel x86_64 + Apple Silicon arm64)
- **Bundle ID:** com.moleheist.game
- **Minimum OS:** macOS 10.12
- **Features:** High-res display support

### Windows Desktop
- **Format:** .exe executable
- **Architecture:** x86_64
- **PCK:** Embedded in executable
- **Company:** Mole Heist Team
- **Product:** Mole Heist
- **Description:** Multiplayer heist game

### Linux
- **Format:** Standalone executable
- **Architecture:** x86_64
- **PCK:** Embedded in executable
- **Executable:** Must be set executable (`chmod +x`)

## Texture Compression

**Enabled:** ETC2 ASTC compression

This is required for:
- Universal macOS builds (arm64 support)
- Mobile platforms (future)
- Better compatibility

## Distribution Notes

### macOS Distribution

For proper distribution:
1. Code sign the .app bundle
2. Notarize with Apple (requires Developer account)
3. Create DMG installer (optional)

See BUILD.md for code signing commands.

### Windows Distribution

- Consider creating installer (NSIS, Inno Setup)
- Be aware of Windows Defender SmartScreen warnings
- Include Visual C++ redistributables if needed

### Linux Distribution

- Distribute as executable
- Consider AppImage or Flatpak for wider compatibility
- Include instructions to make executable

## CI/CD Integration

The build script returns proper exit codes:
- `0` - Build successful
- `1` - Build failed

Example GitHub Actions workflow:

```yaml
- name: Build Game
  run: ./build.sh all
```

See BUILD.md for complete CI/CD example.

## Known Requirements

### Cannot Build Without:
1. ❌ Export templates not installed
2. ❌ Godot executable not found

### Build Script Will:
1. ✅ Detect Godot automatically
2. ✅ Warn if templates missing
3. ✅ Create build directories
4. ✅ Show build progress
5. ✅ Report build sizes
6. ✅ Set correct permissions

## Testing Builds

### macOS
```bash
unzip builds/macos/MoleHeist.zip
open MoleHeist.app
```

### Windows (with Wine on macOS/Linux)
```bash
wine builds/windows/MoleHeist.exe
```

### Linux
```bash
chmod +x builds/linux/MoleHeist.x86_64
./builds/linux/MoleHeist.x86_64
```

## Optimization Tips

### Reduce Build Size
1. Add exclusions to export preset filters
2. Optimize textures
3. Use VRAM compression
4. Strip debug symbols (use --export-release)

### Performance
- Builds are parallelized by default in Godot
- Full rebuild takes ~30-60 seconds for all platforms
- Incremental builds are faster

## Troubleshooting

### "No export template found"
- Install export templates (see above)

### "Godot command not found"
- Use full path: `/Applications/Godot.app/Contents/MacOS/Godot`
- Or add Godot to PATH

### "Cannot export for universal"
- ETC2 ASTC already enabled in project.godot
- Ensure you have latest export templates

### Build succeeds but won't run
- **macOS:** Check code signing/Gatekeeper
- **Windows:** Check antivirus/SmartScreen
- **Linux:** Ensure executable permission

## Next Steps

1. **Install Export Templates**
   ```bash
   # Open Godot Editor
   # Editor → Manage Export Templates → Download and Install
   ```

2. **Build the Game**
   ```bash
   ./build.sh all
   ```

3. **Test Builds**
   - Test each platform build
   - Verify multiplayer works
   - Check performance

4. **Distribution**
   - Code sign (macOS/Windows)
   - Create installers
   - Upload to itch.io, Steam, etc.

## Files Summary

| File | Purpose | Size |
|------|---------|------|
| `export_presets.cfg` | Export configurations | ~8 KB |
| `build.sh` | Build automation script | ~6 KB |
| `BUILD.md` | Build documentation | ~12 KB |
| `project.godot` | Project config (updated) | ~3 KB |
| `.gitignore` | Git ignore (updated) | <1 KB |
| `CLAUDE.md` | Developer guide (updated) | ~15 KB |

**Total:** ~44 KB of build infrastructure

## Success Criteria

✅ Export presets configured for 3 platforms
✅ Build script with automated detection
✅ Comprehensive documentation
✅ ETC2 ASTC texture compression enabled
✅ Git ignores build artifacts
✅ CLAUDE.md updated with build commands

## Conclusion

The project is now fully configured for building on all major platforms. Simply install export templates and run `./build.sh all` to create distributable builds for macOS, Windows, and Linux.
