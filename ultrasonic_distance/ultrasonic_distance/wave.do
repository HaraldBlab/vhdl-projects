onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ultrasonic_tb/clk
add wave -noupdate /ultrasonic_tb/rst
add wave -noupdate /ultrasonic_tb/led
add wave -noupdate /ultrasonic_tb/echo
add wave -noupdate /ultrasonic_tb/DUT/trigger
add wave -noupdate -divider DUT
add wave -noupdate /ultrasonic_tb/DUT/CLOCK
add wave -noupdate /ultrasonic_tb/DUT/LED
add wave -noupdate /ultrasonic_tb/DUT/TRIG
add wave -noupdate /ultrasonic_tb/DUT/ECHO
add wave -noupdate /ultrasonic_tb/DUT/microseconds
add wave -noupdate /ultrasonic_tb/DUT/counter
add wave -noupdate /ultrasonic_tb/DUT/leds
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {1415711 ps} {1416711 ps}
