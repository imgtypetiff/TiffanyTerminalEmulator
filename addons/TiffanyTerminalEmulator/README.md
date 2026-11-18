# TiffanyTerminalEmulator
GodotTerminalByTIffany revamp (:
The login password is "tiff".

An example Terminal is at res://addons/TiffanyTerminalEmulator/TerminalEmulator/assets/scenes/Terminal.tscn.

There are 3 main components of the TiffanyTerminalEmulator:
	The FileSystemEmulator,
	The TerminalEmulator,
	And The TTYSceneManager.

The FileSystemEmulator is initialized in the Terminal autoload, before the TerminalEmulator systems. The TTYSceneManager is loaded last.

The FileSystemEmulator scans user://FILESYSTEM and creates a FSNode to represent each file in the FileRoot.tscn autoload. If you want to unload a FSNode to save on RAM, examine res://addons/TiffanyTerminalEmulator/FileSystemEmulator/Directory.gd.

The TerminalEmulator has two catergories of scripts: Backend and Frontend. The Backend, like the Terminal.gd autoload, assigns TTYs to nodes and runs commands. The Frontend asks to issue/use a TTY, has a UI, and sends commands to the Backend to run. The Backend sends out the output of the command, and the Frontend verifies the output is theirs before displaying it.

TheTTYSceneManager is WIP, but can currently be used to change what TTY is visible/being used. 
