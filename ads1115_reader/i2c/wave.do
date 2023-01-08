onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group TB /i2c_tb/clk
add wave -noupdate -group TB /i2c_tb/rst
add wave -noupdate -group TB /i2c_tb/scl
add wave -noupdate -group TB /i2c_tb/sda
add wave -noupdate -group TB /i2c_tb/cmd_tdata
add wave -noupdate -group TB /i2c_tb/cmd_tvalid
add wave -noupdate -group TB /i2c_tb/cmd_tready
add wave -noupdate -group TB /i2c_tb/rd_tdata
add wave -noupdate -group TB /i2c_tb/rd_tvalid
add wave -noupdate -group TB /i2c_tb/rd_tready
add wave -noupdate -group TB /i2c_tb/nack
add wave -noupdate -expand -group DUT /i2c_tb/DUT/clk
add wave -noupdate -expand -group DUT /i2c_tb/DUT/rst
add wave -noupdate -expand -group DUT /i2c_tb/DUT/scl
add wave -noupdate -expand -group DUT /i2c_tb/DUT/sda
add wave -noupdate -expand -group DUT /i2c_tb/DUT/cmd_tdata
add wave -noupdate -expand -group DUT /i2c_tb/DUT/cmd_tvalid
add wave -noupdate -expand -group DUT /i2c_tb/DUT/cmd_tready
add wave -noupdate -expand -group DUT /i2c_tb/DUT/rd_tdata
add wave -noupdate -expand -group DUT /i2c_tb/DUT/rd_tvalid
add wave -noupdate -expand -group DUT /i2c_tb/DUT/rd_tready
add wave -noupdate -expand -group DUT /i2c_tb/DUT/nack
add wave -noupdate -expand -group DUT /i2c_tb/DUT/state
add wave -noupdate -expand -group DUT /i2c_tb/DUT/scl_i
add wave -noupdate -expand -group DUT /i2c_tb/DUT/sda_i
add wave -noupdate -expand -group DUT /i2c_tb/DUT/clk_cnt
add wave -noupdate -expand -group DUT /i2c_tb/DUT/scl_hp_cnt
add wave -noupdate -expand -group DUT /i2c_tb/DUT/rx_ack_bit_to_send
add wave -noupdate -expand -group DUT /i2c_tb/DUT/byte_to_send
add wave -noupdate -expand -group DUT /i2c_tb/DUT/sample_ack
add wave -noupdate -expand -group DUT /i2c_tb/DUT/sda_delay
add wave -noupdate -expand -group DUT /i2c_tb/DUT/sda_sampled
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {777824 ns} 0}
quietly wave cursor active 1
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
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {858270 ns}
