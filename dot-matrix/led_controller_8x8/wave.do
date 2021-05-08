onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider DUT
add wave -noupdate /led_controller_8x8_tb/DUT/clk
add wave -noupdate /led_controller_8x8_tb/DUT/rst
add wave -noupdate /led_controller_8x8_tb/DUT/led8x8
add wave -noupdate /led_controller_8x8_tb/DUT/rows
add wave -noupdate /led_controller_8x8_tb/DUT/cols
add wave -noupdate /led_controller_8x8_tb/DUT/pulse_counter
add wave -noupdate /led_controller_8x8_tb/DUT/row_counter
add wave -noupdate -divider TB
add wave -noupdate /led_controller_8x8_tb/VC/touched_leds
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0} {{Cursor 2} {20480808071 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 142
configure wave -valuecolwidth 77
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 1
configure wave -timelineunits us
update
WaveRestoreZoom {20587600172 ps} {20587629013 ps}
