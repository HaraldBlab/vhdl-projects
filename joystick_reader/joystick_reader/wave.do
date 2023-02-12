onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group DUT /joystick_reader_tb/DUT/clk
add wave -noupdate -group DUT /joystick_reader_tb/DUT/rst
add wave -noupdate -group DUT /joystick_reader_tb/DUT/scl
add wave -noupdate -group DUT /joystick_reader_tb/DUT/sda
add wave -noupdate -group DUT /joystick_reader_tb/DUT/x_config
add wave -noupdate -group DUT /joystick_reader_tb/DUT/y_config
add wave -noupdate -group DUT /joystick_reader_tb/DUT/ready
add wave -noupdate -group DUT /joystick_reader_tb/DUT/valid
add wave -noupdate -group DUT /joystick_reader_tb/DUT/x_data
add wave -noupdate -group DUT /joystick_reader_tb/DUT/y_data
add wave -noupdate -group DUT /joystick_reader_tb/DUT/write_tdata
add wave -noupdate -group DUT /joystick_reader_tb/DUT/write_tvalid
add wave -noupdate -group DUT /joystick_reader_tb/DUT/write_tready
add wave -noupdate -group DUT /joystick_reader_tb/DUT/read_tdata
add wave -noupdate -group DUT /joystick_reader_tb/DUT/read_tvalid
add wave -noupdate -group DUT /joystick_reader_tb/DUT/read_tready
add wave -noupdate -group DUT /joystick_reader_tb/DUT/config
add wave -noupdate -group DUT /joystick_reader_tb/DUT/output_tvalid
add wave -noupdate -group DUT /joystick_reader_tb/DUT/output_tready
add wave -noupdate -group DUT /joystick_reader_tb/DUT/value
add wave -noupdate -group DUT /joystick_reader_tb/DUT/cmd_tready
add wave -noupdate -group DUT /joystick_reader_tb/DUT/rd_tready
add wave -noupdate -group DUT /joystick_reader_tb/DUT/single_shot
add wave -noupdate -group DUT /joystick_reader_tb/DUT/y_ready
add wave -noupdate -group DUT /joystick_reader_tb/DUT/state
add wave -noupdate -expand -group SINGLE /joystick_reader_tb/DUT/SINGLE/clk
add wave -noupdate -expand -group SINGLE /joystick_reader_tb/DUT/SINGLE/rst
add wave -noupdate -expand -group SINGLE /joystick_reader_tb/DUT/SINGLE/write_tdata
add wave -noupdate -expand -group SINGLE /joystick_reader_tb/DUT/SINGLE/write_tvalid
add wave -noupdate -expand -group SINGLE /joystick_reader_tb/DUT/SINGLE/write_tready
add wave -noupdate -expand -group SINGLE /joystick_reader_tb/DUT/SINGLE/read_tdata
add wave -noupdate -expand -group SINGLE /joystick_reader_tb/DUT/SINGLE/read_tvalid
add wave -noupdate -expand -group SINGLE /joystick_reader_tb/DUT/SINGLE/read_tready
add wave -noupdate -expand -group SINGLE /joystick_reader_tb/DUT/SINGLE/config
add wave -noupdate -expand -group SINGLE /joystick_reader_tb/DUT/SINGLE/ready
add wave -noupdate -expand -group SINGLE /joystick_reader_tb/DUT/SINGLE/valid
add wave -noupdate -expand -group SINGLE /joystick_reader_tb/DUT/SINGLE/value
add wave -noupdate -expand -group SINGLE /joystick_reader_tb/DUT/SINGLE/config_lsb
add wave -noupdate -expand -group SINGLE /joystick_reader_tb/DUT/SINGLE/config_msb
add wave -noupdate -expand -group SINGLE /joystick_reader_tb/DUT/SINGLE/state
add wave -noupdate -expand -group SINGLE /joystick_reader_tb/DUT/SINGLE/write_count
add wave -noupdate -expand -group SINGLE /joystick_reader_tb/DUT/SINGLE/read_count
add wave -noupdate -expand -group SINGLE /joystick_reader_tb/DUT/SINGLE/single_shot
add wave -noupdate -expand -group SINGLE /joystick_reader_tb/DUT/SINGLE/read_next
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
WaveRestoreZoom {2925868912 ps} {2925869912 ps}
