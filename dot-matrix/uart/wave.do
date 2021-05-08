onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider TB
add wave -noupdate /uart_tb/clk
add wave -noupdate /uart_tb/rst
add wave -noupdate /uart_tb/tx_rx
add wave -noupdate -divider UART_TX
add wave -noupdate /uart_tb/UART_TX/start
add wave -noupdate -radix hexadecimal /uart_tb/UART_TX/data
add wave -noupdate /uart_tb/UART_TX/busy
add wave -noupdate /uart_tb/UART_TX/state
add wave -noupdate -divider UART_RX
add wave -noupdate -radix hexadecimal /uart_tb/UART_RX/data
add wave -noupdate /uart_tb/UART_RX/valid
add wave -noupdate /uart_tb/UART_RX/stop_bit_error
add wave -noupdate /uart_tb/UART_RX/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {83332 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 203
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {106837471 ps}
