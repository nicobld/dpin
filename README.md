# dpin

Pin directories which are often used, and cd to them fast and easily.

## Usage

Pin current directory at the end of the list.

	dpin -p

Pin a specified directory with -d, give it an alias with -a.

	dpin -p -a myalias -d $HOME/mydir

Cd to pin index 0 (no options needed).

	dpin 0
	
Cd to pin with alias 'myalias' (no options needed).

	dpin myalias
	dpin myal
	dpin m

List all pins.

	dpin -l

Remove pin index 0.

	dpin -r -n 0

Remove pin with alias 'myalias'.

	dpin -r -a myalias

Remove all pins.

	dpin -c

## Installation

	git clone https://github.com/nicobld/dpin
	cd dpin
	./install

Then depending on your shell :

### bash

	echo 'source dpin.sh' >> ~/.bashrc

### zsh

	echo 'source dpin.sh' >> ~/.zshrc

### fish

	source dpin.fish

## Uninstall

	git clone https://github.com/nicobld/dpin
	cd dpin
	./uninstall

Then :

### bash, zsh

Remove the source line in ~/.bashrc or ~/.zshrc

### fish

	rm ~/.config/fish/functions/dpin.fish