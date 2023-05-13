
dpin() {
	args=()

	for arg in $@
	do
		args+=($arg)
	done

	$HOME/.local/lib/dpin.pl ${args[*]}

	if test -s $HOME/.cache/dpin
	then
		cd $(cat $HOME/.cache/dpin)
	fi
}
