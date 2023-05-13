#!/usr/bin/env fish

function dpin
	for arg in $argv
		set -a args $arg
	end
	$HOME/.local/lib/dpin.pl $args
	if test -s $HOME/.cache/dpin
		cd $(cat $HOME/.cache/dpin)
	end
end

funcsave dpin
