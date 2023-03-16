![TileBitTools](https://github.com/dandeliondino/tile_bit_tools/blob/0.1.1/assets/header.png)

TileBitTools is a Godot 4 plugin for autotile templates and terrain bit editing.

The terrain system in Godot 4 is powerful and extensible, and has a lot of untapped potential. The goal of this plugin is to enable fast iterations, to assist in migrating from Godot 3, and to speed up the learning process for new users.

## Contents
- Features
- Installation
- Use
- Feedback


## Features
- **Built-in autotile templates for all 3 terrain modes**
    - **3x3 minimal**, **3x3 16-tile** and **2x2** templates from Godot 3 documentation.
    - **Blob**, **Wang** and **Wang 3-terrain** templates to match Tilesetter's default export.
    - **Simple 9- and 4-tile** templates. These are modular corner-mode templates that match tile configurations commonly found in spritesheets.
- **Custom user template creation**
    - Save new templates from the terrain bits on existing tiles. Statistics and previews are automatically generated.
    - Use as a quick way to copy-paste terrain bits.
    - Use as a back up for terrain data that was time-consuming to assign in case of crashes or corruption.
    - Create complex, reusable templates and save them to a shared directory accessible to all projects on your computer.
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
*Please back up your project before making any changes. Godot 4 is still new, and TileBitTools is even newer, so unexpected behavior may occur.*

This plugin is located in the **bottom TileSet editor**, in the **Select** tab. To access any of its functions, the first step is to **select the tiles** you want to use.

### To apply a template:
1. Select tiles
2. Expand the "Apply Terrain Template" section and choose a template
    - Filter by tags to narrow the choices
    - Built-in templates all have detailed descriptions. Click the `>` button to expand the text.
    - Built-in templates also come with examples you can use to experiment, or use as guides for arranging tiles in your image editor. Click the image icon to open their folder. Examples in v1.0 are all 16x16px and were adapted from [Kenney's Pixel Shmup](https://www.kenney.nl/assets/pixel-shmup).
3. Assign terrains
    - As you assign terrains, you will see a preview generate
    - If you want to place tiles on a empty background, leave the terrain that doesn't include the center bits empty (this is usually the last one listed)
    - Missing terrains? Only terrain sets and terrains that match the template's terrain mode will be available to choose. You can choose a different template, or create a new terrain set with the correct mode.
4. Click to apply template
    - This cannot be undone. But TileBitTools makes clearing and reassigning terrain bits fast and easy. So do not hesitate to experiment.


### To save a template:
1. Select tiles
2. Expand the "Save Terrain Template" section and click "Save"
3. 




## Warning Regarding Resource Files
Like many other files in a typical Godot project, template terrain data for TileBitTools is saved in plain-text Resource (`.tres`) files.

This plugin will load all `.tres` resource files in the following folder locations:
- Built-in templates folder: `res://addons/tile_bit_tools/templates`
- Project-specific templates folder: `user://addons/tile_bit_tools/templates` (see [Accessing persistent user data (user://)](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html#accessing-persistent-user-data-user) for location)
- Shared templates folder: [EditorPaths.get_data_dir()](https://docs.godotengine.org/en/stable/classes/class_editorpaths.html#class-editorpaths-method-get-data-dir) + `/tile_bit_tools_templates`
- The custom user directory specified in Project Settings -> Addons -> TileBitTools (blank by default)

***If a Resource file in one of these locations contains malicious code, it may be executed by Godot on loading.***

To encounter malicious code would require a user to first separately download a `.tres` file containing the code, and for that user to place it in one of these specific folders. As this plugin is for game developers, not the general public, the potential risk of using this file format was determined to be outweighed by the benefits of: (1) not requiring serialization and (2) allowing users to edit the plain text tile data in an easy-to-read format.

However, there are scenarios where users may want to share template terrain data online. Please exercise caution if doing so. See the [built-in templates here](https://github.com/dandeliondino/tile_bit_tools/tree/main/addons/tile_bit_tools/templates) for examples of what normal template files look like. They will only reference one script (`res://addons/tile_bit_tools/core/template_bit_data.gd`) and should be small in size (a 164-tile template is 14KB on disk).

For more details regarding the risks of sharing Resource files, see this video from GDQuest: ["I was COMPLETELY WRONG about saves in Godot... ( ; - ;)"](https://www.youtube.com/watch?v=j7p7cGj20jU)




## Feedback
Find a bug? -> [Known Bugs and Reports](https://github.com/dandeliondino/tile_bit_tools/issues/2)

Have an autotile template that should be built-in? -> [Add More Built-in Terrain Templates](https://github.com/dandeliondino/tile_bit_tools/issues/4)

Have an idea for a new feature? -> [Future Directions and Suggestions](https://github.com/dandeliondino/tile_bit_tools/issues/3)


## Credits
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