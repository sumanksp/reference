## Scripts
This directory holds all the scripts for productive development

### format-linuxkernel-indent.sh
A robust wrapper for the `indent` utility to enforce Linux Kernel coding standards.

**Features:**
- **Safety:** `-d` flag for dry-runs to preview changes.
- **Efficiency:** `-r` flag for recursive directory scanning.
- **Clarity:** Color-coded terminal output and final success/failure counters.
- **Education:** `-e` flag shows live "Before and After" code examples.

**Usage:**
```bash
./scripts/format-linuxkernel-indent.sh -r ./src
