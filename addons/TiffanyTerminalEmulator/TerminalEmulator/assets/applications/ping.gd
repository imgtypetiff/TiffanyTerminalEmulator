extends TerminalApplication

func _init():
	app_name="Ping"
	description="Ping's ya!"

func run(terminal : Terminal, params: Array, tty_number: int, profile: String):
	schema.add_option("count", "c", "Number of pings.", 4, TerminalArguments.OptionType.INT)
	schema.add_positional("host", "The hostname or IP address to ping.", "example.com")
	
	var _parsed_args = TerminalArguments.parse(params, schema)
	
	var host: String = _parsed_args.positionals[0]
	var count: int = _parsed_args.get_option("count")



	echo("PING %s (???.???.???.???)." % [host])
	for seq in range(1, count + 1):
		if not await _safe_await(1.0): return
		echo(
			"64 bytes from %s: icmp_seq=%d time=%d ms" % [host, seq, 20 + randi() % 10])
	if not await _safe_await(1.0): return
	echo("--- %s ping statistics ---" % host)
	echo(
		"%d packets transmitted, %d received, 0%% packet loss"
		% [count, count]
	)
	

func _safe_await(duration: float) -> bool:
	if not _terminal.ttys[_tty_number].active:
		return false

	await _terminal.get_tree().create_timer(duration).timeout

	return _terminal.ttys[_tty_number].active

func echo(statement: String):
	_terminal.run_command("guest", _tty_number, "echo " + statement)
