# TileBitTools

TileBitTools is a Godot 4 plugin for autotile templates and terrain bit editing.

For the full, up-to-date readme and documentation, see [github.com/dandeliondino/tile_bit_tools](https://github.com/dandeliondino/tile_bit_tools)



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



## Credits
Concept inspired by [Wareya's Godot Tile Setup Helper](https://github.com/wareya/godot-tile-setup-helper) for Godot 3.5

Huge thanks to [YuriSizov's Godot Editor Theme Explorer](https://github.com/YuriSizov/godot-editor-theme-explorer) and [Zylann's Editor Debugger](https://github.com/Zylann/godot_editor_debugger_plugin)

The example tilesets are adapted from [Kenney's Pixel Shmup](https://www.kenney.nl/assets/pixel-shmup) ([License: CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/))

The TileBitTools icon is modified from [Kenney's Game Icons](https://www.kenney.nl/assets/game-icons) ([License: CCO 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/))

The fonts in the header and images are [Lilita One](https://fonts.google.com/specimen/Lilita+One) (SIL Open Font License 1.1) and [Fira Code](https://github.com/tonsky/FiraCode) (SIL Open Font License 1.1).