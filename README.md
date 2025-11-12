# ck.dashboard

**ck.dashboard** is a system monitor implemented as a side panel for Linux desktops running Wayland compositors. It is written in **QtQuick** and based on [Quickshell](https://quickshell.org/).

> **Note:** This project is in a very early stage of development and currently provides only minimal functionality.  
> It is primarily intended for developers rather than end users. Backward-incompatible changes may (and will) be introduced at any time.

## Screenshot

![ck.dashboard screenshot](https://raw.githubusercontent.com/chpock/ck.dashboard/assets/ck.dashboard-screenshot-2025-11-09_23-34.png)

## Features

Currently available components:

- Calendar
- List of the nearest events from **khal** calendar (optional, only if **khal** is installed and configured)
- Network activity monitor
- Memory monitor (RAM and swap) with a list of top memory-consuming processes
- CPU usage monitor with a list of active processes
- Disk usage and activity monitor with available space per mount point

## Dependencies

- [Quickshell](https://quickshell.org/)
- Qt6 with charts support
- [dgop](https://github.com/AvengeMedia/dgop)
- *(optional)* [khal](https://khal.readthedocs.io/en/latest/)

## Installation

1. **Install dependencies**

   For Arch Linux, you can install the required packages with:

   ```bash
   pacman -S quickshell qt6-charts dgop
   ```

2. **Clone the repository**

   ```bash
   mkdir -p ~/.config/quickshell
   cd ~/.config/quickshell
   git clone https://github.com/chpock/ck.dashboard.git
   ```

3. **Run**

   ```bash
   qs -c ck.dashboard
   ```

## Feedback

Feedback, ideas, and feature suggestions are very welcome!

Please feel free to open issues or share your thoughts in the project’s [GitHub repository](https://github.com/chpock/ck.dashboard)

## Copyrights

Copyright (c) 2025 Konstantin Kushnir <chpock@gmail.com>
