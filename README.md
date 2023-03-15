![TileBitTools](https://github.com/dandeliondino/tile_bit_tools/blob/0.1.1/assets/header.png)

TileBitTools is a Godot 4 plugin for autotile templates and terrain bit editing.

The terrain system in Godot 4 is powerful and extensible, and has a lot of untapped potential. The goal of this plugin is to enable fast iterations, to assist in migrating from Godot 3, and to speed up the learning process for new users.

## Contents
- Features
- Installation
- 


## Features
- **Built-in autotile templates for all 3 terrain modes**
    - 3x3 minimal, 3x3 16-tile and 2x2 templates from Godot 3 documentation.
    - Blob, Wang and Wang 3-terrain templates from Tilesetter.
    - Simple 9-tile and 4-tile templates. These are modular corner-mode templates made to match tile configurations commonly found in spritesheets.
- **Custom user template creation**
    - Save new templates from the terrain bits on existing tiles. Statistics and previews are automatically generated.
    - Use as a quick way to copy-paste terrain bits by saving in a project-specific directory.
    - Or create reusable templates and save them to a shared directory accessible to all projects on your computer.
- **Bulk tile bit editing buttons**
    - **Fill** - fill all selected tiles' terrain bits with a single terrain.
    - **Set Bits** - set a specific bit to a single terrain in all selected tiles.
    - **Clear** - clear all terrain assignments from selected tiles.


## Installation

### From the Godot Asset Library:
*TileBitTools is pending review on the Godot Asset Library. This page will be updated with a link once it is available for download.*

### From Github:
1. Go to Releases (right side of this page) to download the latest stable version.
2. Unzip and move the `addons/tile_bit_tools` folder to your project
3. Go to Project Settings -> Plugins and enable TileBitTools

### To Uninstall
It is safe to remove TileBitTools from your project at any time. Saved user templates will remain available if TileBitTools is reinstalled, unless they are manually deleted.

1. Delete the `addons/tile_bit_tools` folder from your project


## Use
*TileBitTools is still experimental, please back up first.*
1. Select tiles in the bottom TileSet editor
2. Choose a template
3. Assign terrains
4. Click to apply template

![1. Select tiles](https://github.com/dandeliondino/tile_bit_tools/blob/0.1.1/assets/tutorial_screenshot_01.png)

![2. Choose template](https://github.com/dandeliondino/tile_bit_tools/blob/0.1.1/assets/tutorial_screenshot_02.png)

![3. Assign terrains](https://github.com/dandeliondino/tile_bit_tools/blob/0.1.1/assets/tutorial_screenshot_03.png)

![4. Apply template](https://github.com/dandeliondino/tile_bit_tools/blob/0.1.1/assets/tutorial_screenshot_04.png)

![Results](https://github.com/dandeliondino/tile_bit_tools/blob/0.1.1/assets/tutorial_screenshot_05.png)

## Feedback:
Find a bug? -> [Known Bugs and Reports](https://github.com/dandeliondino/tile_bit_tools/issues/2)

Have an autotile template that should be built-in? -> [Add More Built-in Terrain Templates](https://github.com/dandeliondino/tile_bit_tools/issues/4)

Have an idea for a new feature? -> [Future Directions and Suggestions](https://github.com/dandeliondino/tile_bit_tools/issues/3)


# Credits
Concept inspired by [Wareya's Godot Tile Setup Helper](https://github.com/wareya/godot-tile-setup-helper) for Godot 3.5

Huge thanks to [YuriSizov's Godot Editor Theme Explorer](https://github.com/YuriSizov/godot-editor-theme-explorer) and [Zylann's Editor Debugger](https://github.com/Zylann/godot_editor_debugger_plugin)

The example tilesets are adapted from [Kenney's Pixel Shmup](https://www.kenney.nl/assets/pixel-shmup) ([License: CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/))

The TileBitTools icon is modified from [Kenney's Game Icons](https://www.kenney.nl/assets/game-icons) ([License: CCO 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/))

The fonts in the header are [Lilita One](https://fonts.google.com/specimen/Lilita+One) (SIL Open Font License 1.1) and [Fira Code](https://github.com/tonsky/FiraCode) (SIL Open Font License 1.1).

Other icons included with this addon are from the Godot 4 editor with the following license:
>Copyright (c) 2014-present Godot Engine contributors (see AUTHORS.md).
>Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.

>Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

>The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.