# Quasar Installation Guide

## Requirements

### System Requirements
- **SuperCollider**: 3.13.0 or later
- **Operating System**: macOS, Linux, or Windows
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 500MB for software, additional space for samples

### Optional Requirements
- **Python 3.8+**: For Klotho integration (QKlotho framework)
- **Git**: For version control
- **Audio Interface**: For realtime performance
- **MIDI Controller**: For macro control and live performance

---

## Installation Methods

### Method 1: Install as SuperCollider Quark (Recommended)

**Note**: This method will be available after the first release.

```supercollider
// In SuperCollider
Quarks.install("Quasar");
```

### Method 2: Manual Installation from Source

#### Step 1: Clone the Repository

```bash
cd ~/path/to/your/quarks
git clone https://github.com/yourusername/quasar.git Quasar
```

#### Step 2: Add to SuperCollider Extensions

**Option A: Symlink** (Recommended for development)

```bash
# On macOS/Linux
ln -s ~/path/to/quarks/Quasar ~/Library/Application\ Support/SuperCollider/Extensions/Quasar

# On Windows (run as Administrator)
mklink /D "%USERPROFILE%\AppData\Local\SuperCollider\Extensions\Quasar" "C:\path\to\quarks\Quasar"
```

**Option B: Copy**

Copy the entire Quasar folder to your SuperCollider Extensions directory:
- macOS: `~/Library/Application Support/SuperCollider/Extensions/`
- Linux: `~/.local/share/SuperCollider/Extensions/`
- Windows: `%USERPROFILE%\AppData\Local\SuperCollider\Extensions\`

#### Step 3: Recompile Class Library

In SuperCollider:
1. Press `Cmd+Shift+L` (macOS) or `Ctrl+Shift+L` (Linux/Windows)
2. Or select `Language > Recompile Class Library`

#### Step 4: Verify Installation

```supercollider
// Test that Quasar is loaded
QProject.postln;
// Should print: QProject

// Check version
Quasar.version;
// Should print: 0.0.1
```

---

## Klotho Integration (Optional)

To use the QKlotho framework for advanced CAC features:

### Step 1: Install Python Dependencies

```bash
cd /path/to/Quasar
pip install -r Klotho/Klotho/requirements.txt
```

### Step 2: Install Klotho Python Package

```bash
cd Klotho/Klotho
pip install -e .
```

### Step 3: Test Klotho Bridge

```supercollider
// In SuperCollider
k = QKlotho();
k.test; // Should connect to Python and return status
```

---

## Post-Installation Setup

### Configure Audio Device

```supercollider
// Check available audio devices
ServerOptions.devices;

// Set your audio device
s.options.device = "Your Audio Interface";

// Configure buffer settings
s.options.numBuffers = 2048;
s.options.memSize = 8192 * 16;

// Boot the server
s.boot;
```

### Load Sample Resources (Optional)

If you have sample libraries, configure the resource path:

```supercollider
// Set sample path
Quasar.samplePath = "~/Music/Samples/";

// Or load specific libraries
QProject.loadSampleLibrary("~/Music/Samples/MyKit/");
```

---

## Troubleshooting

### Issue: "Quasar not found" after installation

**Solution**: Make sure you've recompiled the class library and that the Quasar folder is in the correct Extensions directory.

### Issue: Python bridge not connecting (QKlotho)

**Solution**:
1. Verify Python is installed: `python3 --version`
2. Check Klotho is installed: `python3 -c "import klotho; print(klotho.__version__)"`
3. Check Python OSC library: `pip install python-osc`

### Issue: Audio dropouts or glitches

**Solution**:
1. Increase buffer size: `s.options.blockSize = 128` (or 256)
2. Increase memory: `s.options.memSize = 8192 * 32`
3. Reduce number of simultaneous voices
4. Use NRT rendering for complex pieces

### Issue: Out of memory errors

**Solution**:
```supercollider
s.options.memSize = 8192 * 64; // Increase memory
s.quit;
s.boot;
```

---

## Updating Quasar

### If Installed via Quarks

```supercollider
Quarks.update("Quasar");
```

### If Installed Manually

```bash
cd /path/to/Quasar
git pull origin main
```

Then recompile the class library in SuperCollider.

---

## Uninstallation

### If Installed via Quarks

```supercollider
Quarks.uninstall("Quasar");
```

### If Installed Manually

Simply delete the Quasar folder from your Extensions directory, then recompile the class library.

---

## Next Steps

After installation:
1. Read the [Quick Start Guide](docs/QuickStart.md)
2. Try the [Tutorial Series](docs/tutorials/)
3. Explore [Example Compositions](examples/)
4. Join the community at [scsynth.org](https://scsynth.org/)

---

## Getting Help

- **Documentation**: See [docs/](docs/)
- **Examples**: See [examples/](examples/)
- **Issues**: [GitHub Issues](https://github.com/yourusername/quasar/issues)
- **Forum**: [scsynth.org](https://scsynth.org/)
- **Discord**: [Quasar Community](https://discord.gg/quasar)

---

**Installation Status**: Phase Zero - Pre-Alpha
**Last Updated**: 2026-01-08
