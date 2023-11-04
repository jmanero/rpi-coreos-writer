CoreOS Raspberry Pi Builder
===========================

Build Fedora CoreOS SD cards for Raspberry Pi 4 boards with RPI_EFI and full firmware device-tree support.

## Usage

- Cache image and firmware archives:

  ```
  make cache
  ```

- Write Fedora CoreOS, Raspberry Pi firmware, and the `RPI_EFI` EDK2 boot-loader an SD card:

  ```
  sudo make install DEVICE=/dev/YOUR_SD_CARD IGNITION_URL=https://your.ignition/json/file
  ```

- Put the SD card into your Raspberry Pi
- Connect ethernet and power; your device will boot Fedora CoreOS and apply the bundled Ignition configuration.

> **NOTE**
> First-boot may take up to 5 minutes to provision in an accessible SSH server. Subsequent boots take up to a minute due to the time required to load and decompress the kernel from the SD card into memory. You may want to attach a monitor to observe a few boot-cycles for your sanity... Using a USB-3 storage device for a boot disk instead of the SD card may improve this at the expense of tying up one of your board's precious USB-3 ports.

### Bundled `RPI_EFI.fd`

The `efi-1.34` directory contains a modified `config.txt` and a pre-configured instance of the `RPI_EFI.fd` boot-loader from [pftf/RPi4](https://github.com/pftf/RPi4). The EFI interface persists configuration from the setup interface (accessed by pressing `[esc]` at startup) within itself. The instance included herein has the 3GB memory limit disables, firmware device-tree enabled, and the memory-card slot set as the next boot device to achieve the mystical Headless Raspberry Pi Provisioning Experience™.
