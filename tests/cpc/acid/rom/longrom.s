org &c000

defb 1
defb 1
defb 0
defb 1
defw command_table
command_table:
defw start
defw go
defb "STAR","T"+&80
defb "G","O"+&80
defb 0

start:
ret

go:
ret

org &ffff
defb 0

