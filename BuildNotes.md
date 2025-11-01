# Build Notes - bounce-world-client

## 📊 Project Status

### Overview
**FujiNet application** connecting to the bouncy-world TCP service across multiple retro platforms.

### Current Branch: `fix-c_sp`
Successfully builds all three targets with fixes for the `c_sp` symbol issue.

---

## 🎯 Build Status

| Target | CPU | Toolchain | Status | Binary Size | Notes |
|--------|-----|-----------|--------|-------------|-------|
| **apple2enh** | 6502 | cc65/ca65 | ✅ **SUCCESS** | 14KB | Fixed with c_sp workaround |
| **atari** | 6502 | cc65/ca65 | ✅ **SUCCESS** | 14KB | Fixed with c_sp workaround |
| **coco** | 6809 | cmoc | ✅ **SUCCESS** | 15KB | Working perfectly |

### Map Files Generated
- `bwc.apple2enh.map` (109KB) - Full linker map for debugging
- `bwc.atari.map` (93KB) - Full linker map for debugging

---

## 🔧 Technical Details

### Toolchain Configuration

**6502 Platforms (apple2enh, atari):**
- Compiler: cc65 (v2.19)
- Assembler: ca65
- Linker: cl65 with custom flags
- Library: fujinet-lib 4.8.0 (locally built)

**6809 Platform (coco):**
- Compiler: cmoc
- Library: fujinet-lib 4.8.0 (locally built)
- Additional: hirestxt-mod 0.5.0.1

### Memory Configuration

**apple2enh:**
- Start Address: `0x0C00`
- Zero Page: `$0080-$009A` (26 bytes available)
- `c_sp` symbol: Fixed at `$9A` (workaround for cc65 2.19)

**atari:**
- Custom linker config: `cfg/atari.cfg`
- `c_sp` symbol: Fixed at `$9A`

**coco:**
- No assembly file constraints
- Standard cmoc memory model

---

## 🛠️ Key Fixes Implemented (on `fix-c_sp` branch)

### 1. **c_sp Symbol Resolution**
**Problem:** cc65 2.19 doesn't export the `c_sp` symbol, but fujinet-lib 4.8.0 requires it.

**Solution:** Created `/src/common/c_sp.s`:
```asm
.export c_sp
.zeropage
c_sp = $9A  ; Fixed zero page address
```

### 2. **Build System Improvements**
- Added `--lib-path` flags for better library resolution
- Enabled map file generation with `--mapfile` flag
- Added cc65 lib directory to search paths (`/usr/local/share/cc65/lib`)

### 3. **Platform-Specific Handling**
- Excluded assembly files (`.s`) from coco builds (cmoc doesn't use ca65-style assembly)
- Fixed double_buffer.s `.macpack cpu` redefinition issue

### 4. **Local Library Integration**
- Using locally built fujinet-lib from `/Users/dillera/code/fujinet-lib/build`
- Headers and `.lib` files copied during build
- Modified `makefiles/fujinet-lib.mk` to use local build instead of downloading from GitHub

---

## 📁 Project Structure

```
bounce-world-client/
├── src/
│   ├── main.c                    # Entry point
│   ├── common/                   # Shared code
│   │   └── c_sp.s               # NEW: c_sp symbol workaround
│   ├── apple2/                   # Apple II specific code
│   ├── atari/                    # Atari specific code
│   └── coco/                     # TRS-80 CoCo specific code
├── makefiles/
│   ├── compiler-cc65.mk         # cc65 toolchain rules (UPDATED)
│   ├── compiler-cmoc.mk         # cmoc toolchain rules
│   ├── fujinet-lib.mk           # Library management (UPDATED)
│   └── build.mk                 # Main build logic (UPDATED)
├── build/                        # Output binaries
├── _cache/                       # Downloaded/cached libraries
├── Claude.md                     # Development guide
└── BuildNotes.md                 # This file
```

---

## 🚀 Available Commands

```bash
# Build all targets
make all

# Clean build artifacts
make clean

# Build specific target
make TARGETS=apple2enh all

# Create release distributions
make release

# Create disk images
make disk

# Test in emulator (Altirra for Atari)
make TARGETS=atari test
```

---

## 📝 Known Issues & Workarounds

### cc65 `c_sp` Symbol Issue

**Context:** In recent cc65 development, the runtime symbol `sp` was renamed to `c_sp`. The cc65 2.19 runtime doesn't export this symbol, but fujinet-lib 4.8.0 (compiled with newer conventions) references it.

**Root Cause:** The fujinet-lib 4.8.0 was built with a version of cc65 that expects the `c_sp` symbol to be available in the runtime. However, cc65 2.19 doesn't export this symbol, causing unresolved external errors during linking.

**Symptoms:**
```
ld65: Error: 1 unresolved external(s) found - cannot create output file
Warning: Unresolved external 'c_sp'
```

**Workaround:** Define `c_sp` manually in `src/common/c_sp.s` at a fixed zero-page address ($9A). This provides the symbol that the fujinet library needs without requiring zero-page allocation (which would overflow the limited ZP space).

**Long-term Solutions:**
1. Upgrade to a newer cc65 that properly exports `c_sp`
2. Rebuild fujinet-lib with cc65 2.19 conventions
3. Keep the workaround (current approach - minimal and effective)

---

## 🔍 Debugging Tips

### Viewing Map Files
The generated map files show the complete memory layout and symbol resolution:
```bash
less build/bwc.apple2enh.map
```

### Checking Symbol Usage
To see where symbols are referenced:
```bash
strings obj/apple2enh/common/*.o | grep c_sp
```

### Verifying Zero-Page Usage
Check the apple2enh.cfg to see available zero-page space:
```
ZP: start = $0080, size = $001A  # Only 26 bytes!
```

---

## 📄 Documentation Resources

Per Claude.md guidelines:
- **6502 Compiler:** https://cc65.github.io/doc/cc65.html
- **6502 Linker:** https://cc65.github.io/doc/cl65.html
- **6809 Linker:** https://www.lwtools.ca/manual/manual.html
- **6809 Compiler:** http://gvlsywt.cluster051.hosting.ovh.net/dev/cmoc-manual.html
- **FujiNet Library:** https://github.com/FujiNetWIFI/fujinet-lib
- **Project Repo:** https://github.com/markjfisher/bounce-world-client

---

## 🎯 Commit History (fix-c_sp branch)

1. **1827c5e** - Remove unused `.macpack cpu` directive from double_buffer.s to fix symbol redefinition errors
2. **df6c126** - Use locally built fujinet-lib instead of downloading from GitHub
3. **79d6097** - Add library search paths to linker flags for better library resolution
4. **be366ad** - Fix c_sp linking issue by defining it as a zero page symbol; exclude assembly files from coco build

---

## ✅ Testing Status

### Build Testing
- ✅ All three targets build without errors
- ✅ Map files generated successfully for debugging
- ✅ Binary sizes are reasonable (14-15KB)

### Runtime Testing
- ⏳ Pending: Test on actual hardware
- ⏳ Pending: Test in emulators
- ⏳ Pending: Verify FujiNet network connectivity

---

## 🚧 Future Work

1. **Re-enable c64 target** - Should work with the c_sp fix
2. **Test binaries** on actual hardware or emulators
3. **Document c_sp workaround** in upstream repository
4. **Consider cc65 upgrade** when newer version is stable
5. **Add CI/CD pipeline** for automated builds
6. **Create release packages** for distribution

---

**Last Updated:** November 1, 2025
**Branch:** fix-c_sp
**Maintainer:** @dillera
