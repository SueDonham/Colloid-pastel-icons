# Colloid Pastel Cursors
Xcursor and hyprcursor themes based on those of [Colloid-icon-theme](https://github.com/vinceliuice/Colloid-icon-theme/tree/main/cursors).

![01](preview.png)


## Installation
### Manual
Copy the compiled theme(s), located in the /dist subdirectories, to your icons directory.

### Scripted
- Open a terminal in the cursors subdirectory of the [icon theme](https://github.com/SueDonham/Colloid-pastel-icons).
- For user-level installation, run `./install.sh`
- For system-wide installation, run `sudo ./install.sh`

The interactive script offers to install the XCursor theme, hyprcursor theme, or both.

## Modifying or building Xcursors from source
Dependencies: [xorg-xcursorgen](https://gitlab.freedesktop.org/xorg/app/xcursorgen) and [inkscape](https://inkscape.org/).

[build.sh](./build.sh) creates two cursor themes (light and dark) based on the images in [/src](./src) and the sizes and hotspots in the .cursor files found in [/src/config](./src/config).
