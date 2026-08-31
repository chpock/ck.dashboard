# quickdashboard

**quickdashboard** is a system monitor implemented as a side panel for Linux desktops running Wayland compositors. It is written in **QtQuick** and based on [Quickshell](https://quickshell.org/).

> **Note:** This project is in a very early stage of development and currently provides only minimal functionality.  
> It is primarily intended for developers rather than end users. Backward-incompatible changes may (and will) be introduced at any time.

## Screenshot

![quickdashboard screenshot](https://raw.githubusercontent.com/chpock/quickdashboard/assets/ck.dashboard-screenshot-2025-11-09_23-34.png)

## Features

Currently available components:

- Calendar
- List of the nearest events from **khal** calendar (optional, only if **khal** is installed and configured)
- Network monitor that includes:
  - Current WiFi network and its level
  - Latency (ping time) for well-known hosts
  - DNS resolution health and its latency
  - Default gateway IP and its latency
  - Download/upload rates
- Memory monitor (RAM and swap) with a list of top memory-consuming processes
- CPU usage monitor with a list of active processes
- Disk usage and activity monitor with available space per mount point
- Current track playing from media players (using MPRIS)
- Audio input/output volume (using pipewire)
- Custom buttons for any actions
- Clock
- Usage limits and quotas for AI providers (optional, only if **openusage-cli** is installed and configured)

## Dependencies

- [Quickshell](https://quickshell.org/)
- Qt6 with graphs support (`qt6-graphs` on Arch Linux)
- [dgop](https://github.com/AvengeMedia/dgop)
- *(optional)* [khal](https://khal.readthedocs.io/en/latest/)
- *(optional)* [openusage-cli](https://github.com/chpock/openusage-cli)

## Installation

1. **Install dependencies**

   For Arch Linux, you can install the required packages with:

   ```bash
   pacman -S quickshell qt6-graphs dgop
   ```

2. **Clone the repository**

   ```bash
   git clone https://github.com/chpock/quickdashboard.git
   cd quickdashboard
   ```

3. **Run**

   ```bash
   ./bin/quickdashboard
   ```

## Disk mount filtering

The `Disk` widget can hide mount entries by filesystem type and/or mount point:

```qml
W.Disk {
    exclude: ({
        fstype: ["tmpfs", "overlay"],
        mount: ["/run/*", "/mnt/?"],
    })
}
```

Each list contains case-sensitive glob patterns matched against the complete value. `*` matches any sequence of characters, including `/`, and `?` matches one character. An entry is hidden when either its `fstype` or its mount point matches any configured pattern. Missing or empty lists do not filter that field.

To change the filter at runtime, assign a new `exclude` object rather than mutating its arrays in place.

Disk read and write rates remain system-wide because they are aggregated across all disks.

## Feedback

Feedback, ideas, and feature suggestions are very welcome!

Please feel free to open issues or share your thoughts in the project’s [GitHub repository](https://github.com/chpock/quickdashboard)

## Copyrights

Copyright (c) 2025-2026 Kostiantyn Kushnir <chpock@gmail.com>
