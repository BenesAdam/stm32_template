# STM32 project template

## Prerequisites

You need to have the following installed and properly setup. Ensure that they are available in your path.

- [GNU ARM Embedded tools](https://developer.arm.com/downloads/-/gnu-rm)
- [GNU Make](https://www.gnu.org/software/make/)

### When using vscode

You'll want to install some extensions to make development smoother

- `C/C++`
- `Cortex-Debug`

## Repo setup

```bash
# Clone the repo
git clone git@github.com:BenesAdam/stm32_template.git
cd stm32_template

# Make sure you have selected the right version of STM32 F in app makefile

# Make sure you have right linker script for you version of STM

# Configure libopencm3
# 1. choose target and remove not used in macro TARGETS in Makefile
# 2. remove all unnecessary folders in include and lib file.
#    - all unwanted platforms
#    - all stm32 f*

# Example for STM32F1
# remove all but (you can find this in target's makefile in macro VPATH):
# - cm3
# - dispatch
# - ethernet
# - stm32
# - usb
# in stm32 folder remove all folders but:
# - common
# - f1

# Build the main application firmware
make
```

## ST-Link Debugger

Install the [ST-Link drivers](https://www.st.com/en/development-tools/stsw-link009.html).

You'll also need to install the [open source ST-Link debugging tools](https://github.com/stlink-org/stlink). The primary application you'll need from that tool-set is *stutil*. Verify that *stutil* is available in your path before attempting to use the VSCode ST-Link debugging tasks.

Once your drivers and debugging tools are installed, you can use the "ST-Link: Debug Application" and "ST-Link: Attach active" VSCode tasks to debug your firmware over ST-Link.
