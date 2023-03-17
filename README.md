![TileBitTools](https://raw.githubusercontent.com/dandeliondino/tile_bit_tools/main/assets/header.png)

TileBitTools is a Godot 4 plugin for autotile templates and terrain bit editing.

The terrain system in Godot 4 is powerful and extensible, and has a lot of untapped potential. The goal of this plugin is to enable fast iterations, to assist in migrating from Godot 3, and to speed up the learning process for new users.

## Contents
- Features
- Installation
- How to use
    - Terrain bit editing buttons
    - Apply a template
    - Save a template
    - Edit a template
    - Delete a template
- Warning Regarding Resource Files
- Feedback
- Credits


## Features
- **Built-in autotile templates for all three Godot 4 terrain modes**
    - **3x3 minimal**, **3x3 16-tile** and **2x2** templates from Godot 3 documentation.
    - **Blob**, **Wang** and **Wang 3-terrain** templates to match Tilesetter's default export.
    - **Simple 9- and 4-tile** templates. These are modular corner-mode templates that match tile configurations commonly found in spritesheets.
- **Tips and example tiles for all built-in templates**
- **Terrain bit editing buttons** to make changes like 'Fill' and 'Clear' to multiple tiles or peering bits in one click
- **Custom user template creation**
    - Save new templates from the terrain peering bits on existing tiles. Statistics and previews are automatically generated.
    - Use as a quick way to copy-paste terrain bits.
    - Or use to save complex, reusable templates to a shared directory accessible to all projects.
- **Options in Project Settings**
    - Customize the template bit colors (default colors are from the color-blind-friendly 'bright' scheme from [Paul Tol](https://personal.sron.nl/~pault/))
    - Customize which messages appear in the Output log
    - Customize the template save folder location


### Limitations
- Even using Godot 3 autotile templates, tile placement will not work exactly the same as it did in Godot 3, as the core matching algorithm is different
- Hex and isometric tiles are not supported
- Alternative tiles are not supported


## Installation

### From the Godot Asset Library:
*TileBitTools is pending review on the Godot Asset Library. This Readme will be updated with a link once it is available for download.*

### From Github:
1. Go to Releases (right side of this page) to download the latest stable version.
2. Unzip and move the `addons/tile_bit_tools` folder to your project
3. Go to Project Settings -> Plugins and enable TileBitTools

### To Uninstall
*It is safe to remove TileBitTools from your project at any time. Saved user templates will remain available if TileBitTools is reinstalled, unless they are manually deleted.*

1. Delete the `addons/tile_bit_tools` folder from your project


## How to use
*Please back up your project before making any changes. Godot 4 is still new, and TileBitTools is even newer, so unexpected behavior may occur.*

TileBitTools is located in the bottom TileSet editor, in the Select tab. To access any of its functions, the first step is to select tiles.

### Terrain bit editing buttons
- **Fill** - fill all selected tiles' terrain data with a single terrain.
- **Set Bits** - set the terrain ID or a specific terrain peering bit to a single terrain in all selected tiles.
- **Clear** - clear all terrain data from selected tiles.

### Apply a template:
![](https://raw.githubusercontent.com/dandeliondino/tile_bit_tools/main/assets/tutorials/apply_template.gif)

1. **Select tiles**
2. **Expand the `Apply Terrain Template` section and choose a template**
    - Press `Select Tag to Filter...` to narrow the choices
    - Built-in templates all have detailed descriptions. Click the `>` button to expand the text.
    - Built-in templates also come with examples you can use for experimenting or as guides for arranging tiles in an image editor. Click the `Examples` button (top-right of the template preview image) to open the folder for that template. Examples in v1.0 are all adapted from [Kenney's Pixel Shmup](https://www.kenney.nl/assets/pixel-shmup) (CC0).
3. **Assign terrains**
    - As you assign terrains, you will see a preview generate.
    - To place tiles on a empty background, leave the terrain that doesn't include the center bits empty (this is usually the last one listed).
    - Missing terrains? Only terrain sets and terrains that match the template's terrain mode will be available to choose. You can choose a different template, or create a new terrain set with the correct mode.
4. **Click Apply Changes (no undo)**
    - This cannot be undone. But TileBitTools makes clearing and reassigning terrain bits fast and easy. Back up, but do not hesitate to experiment.


### Save a template:
1. **Select tiles**
2. **Expand the `Save Terrain Template` section and press `Save Template`**
3. **Enter information in the Save Terrain Template dialog**
    - Statistics/Preview
        - You may see one more terrain here than you expect. If there were any empty bits in your selected tiles, the template generator will have assigned them to an additional terrain.
            - When applying the template, you can leave the extra terrain blank and TileBitTools will leave those bits empty.
            - You can also use this feature as a shortcut: skip assigning a second (or third) terrain when you originally paint your terrain, save the tiles as a user template, then apply the template and assign a terrain to the formerly unassigned bits.
    - Name
    - Description - Optional.
    - Custom Tags - comma-separated text that will allow filtering; spaces in tag names are ok.
    - Save Folder (see: Warning Regarding Resource Files)
        - Project Templates Folder: Templates saved here will only be available for this project.
        - Shared Templates Folder: Templates saved here will be available for any other projects on this computer that have TileBitTools installed
        - User Templates Folder: This option will only appear if there is a directory specified in *Project Settings -> Addons -> TileBitTools*. This is intended for users who want templates in a specific location, such as a subfolder of the main project or in a git repository.
4. **Press `Save`.**
    - If "Show User Messages" is enabled in *Project Settings -> Addons -> TileBitTools*, you will see a confirmation in the output log that includes the save path.
    - The template should immediately be available in the Template drop-down. Any custom tags will appear in `Select Tag to Filter...`
    - All user templates are automatically assigned a user tag. Filter by "Type: User" to see only your own custom templates in the Template drop-down.


### Edit a template:
1. **Select tiles** 
    - Even if you are not planning to edit them, at least one normal (non-alternative) tile must be selected to open TileBitTools
2. **Select template**
    - Filter by "Type: User" to see templates available to edit.
3. **Click the `Edit` button** (top-right of the template preview image)
4. **Make changes in the Edit Terrain Template dialog**
    - Name
    - Description
    - Custom tags
    - Save folder - this cannot be changed from within TileBitTools
    - Saved terrain data cannot be edited inside of TileBitTools. You can use the advanced techniques below to edit the files manually. But it may be easier to simply apply the template to tiles, make edits, then save as a new user template. The old template can then be deleted.
5. **Press `Save`**

#### Advanced edits
- User templates can be moved from one user folder to another manually in the file system.
- Terrain templates are plain-text Resource files (see: *Warning Regarding Resource Files*). You can open them in any text editor to make small changes or find-replace.
- If you are making complex changes, you may want to extend [TemplateBitData](https://github.com/dandeliondino/tile_bit_tools/blob/main/addons/tile_bit_tools/core/template_bit_data.gd), the Resource script. It inherits [BitData](https://github.com/dandeliondino/tile_bit_tools/blob/main/addons/tile_bit_tools/core/bit_data.gd), which contains some helpful iterators and terrain bit manipulation functions.

*After making any changes outside of Godot, go to Project Settings -> Plugins and toggle TileBitTools off and on again to reload the templates.*


### Delete a template:
1. Select tiles
2. Select template
3. Click the `Delete` button (top-right of the template preview image)


## Warning Regarding Resource Files
Like many other files in a typical Godot project, template terrain data for TileBitTools is saved in plain-text Resource (`.tres`) files.

This plugin will load all `.tres` resource files in the following folder locations:
- Built-in templates folder: `res://addons/tile_bit_tools/templates`
- Project-specific templates folder: `user://addons/tile_bit_tools/templates` (see [Accessing persistent user data (user://)](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html#accessing-persistent-user-data-user) for location)
- Shared templates folder: [EditorPaths.get_data_dir()](https://docs.godotengine.org/en/stable/classes/class_editorpaths.html#class-editorpaths-method-get-data-dir) + `/tile_bit_tools_templates`
- The custom user directory specified in *Project Settings -> Addons -> TileBitTools* (blank by default)

**If a Resource file in one of these locations contains malicious code, it may be executed by Godot on loading.**

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

The fonts in the header and images are [Lilita One](https://fonts.google.com/specimen/Lilita+One) (SIL Open Font License 1.1) and [Fira Code](https://github.com/tonsky/FiraCode) (SIL Open Font License 1.1).
