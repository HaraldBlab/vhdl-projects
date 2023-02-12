onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group DUT /ads1115_reader_tb/DUT/clk
add wave -noupdate -group DUT /ads1115_reader_tb/DUT/rst
add wave -noupdate -group DUT /ads1115_reader_tb/DUT/scl
add wave -noupdate -group DUT /ads1115_reader_tb/DUT/sda
add wave -noupdate -group DUT /ads1115_reader_tb/DUT/ready
add wave -noupdate -group DUT /ads1115_reader_tb/DUT/valid
add wave -noupdate -group DUT /ads1115_reader_tb/DUT/data
add wave -noupdate -group DUT /ads1115_reader_tb/DUT/write_tdata
add wave -noupdate -group DUT /ads1115_reader_tb/DUT/write_tvalid
add wave -noupdate -group DUT /ads1115_reader_tb/DUT/write_tready
add wave -noupdate -group DUT /ads1115_reader_tb/DUT/read_tdata
add wave -noupdate -group DUT /ads1115_reader_tb/DUT/read_tvalid
add wave -noupdate -group DUT /ads1115_reader_tb/DUT/read_tready
add wave -noupdate -group DUT /ads1115_reader_tb/DUT/value
add wave -noupdate -group DUT /ads1115_reader_tb/DUT/state
add wave -noupdate -expand -group SINGLE /ads1115_reader_tb/DUT/SINGLE/clk
add wave -noupdate -expand -group SINGLE /ads1115_reader_tb/DUT/SINGLE/rst
add wave -noupdate -expand -group SINGLE /ads1115_reader_tb/DUT/SINGLE/config
add wave -noupdate -expand -group SINGLE /ads1115_reader_tb/DUT/SINGLE/write_tdata
add wave -noupdate -expand -group SINGLE /ads1115_reader_tb/DUT/SINGLE/write_tvalid
add wave -noupdate -expand -group SINGLE /ads1115_reader_tb/DUT/SINGLE/write_tready
add wave -noupdate -expand -group SINGLE /ads1115_reader_tb/DUT/SINGLE/read_tdata
add wave -noupdate -expand -group SINGLE /ads1115_reader_tb/DUT/SINGLE/read_tvalid
add wave -noupdate -expand -group SINGLE /ads1115_reader_tb/DUT/SINGLE/read_tready
add wave -noupdate -expand -group SINGLE /ads1115_reader_tb/DUT/SINGLE/ready
add wave -noupdate -expand -group SINGLE /ads1115_reader_tb/DUT/SINGLE/valid
add wave -noupdate -expand -group SINGLE /ads1115_reader_tb/DUT/SINGLE/value
add wave -noupdate -expand -group SINGLE /ads1115_reader_tb/DUT/SINGLE/state
add wave -noupdate -expand -group SINGLE /ads1115_reader_tb/DUT/SINGLE/write_count
add wave -noupdate -expand -group SINGLE /ads1115_reader_tb/DUT/SINGLE/read_count
add wave -noupdate -group I2C /ads1115_reader_tb/DUT/I2C_CONTROLLER/clk
add wave -noupdate -group I2C /ads1115_reader_tb/DUT/I2C_CONTROLLER/rst
add wave -noupdate -group I2C /ads1115_reader_tb/DUT/I2C_CONTROLLER/scl
add wave -noupdate -group I2C /ads1115_reader_tb/DUT/I2C_CONTROLLER/sda
add wave -noupdate -group I2C /ads1115_reader_tb/DUT/I2C_CONTROLLER/cmd_tdata
add wave -noupdate -group I2C /ads1115_reader_tb/DUT/I2C_CONTROLLER/cmd_tvalid
add wave -noupdate -group I2C /ads1115_reader_tb/DUT/I2C_CONTROLLER/cmd_tready
add wave -noupdate -group I2C /ads1115_reader_tb/DUT/I2C_CONTROLLER/rd_tdata
add wave -noupdate -group I2C /ads1115_reader_tb/DUT/I2C_CONTROLLER/rd_tvalid
add wave -noupdate -group I2C /ads1115_reader_tb/DUT/I2C_CONTROLLER/rd_tready
add wave -noupdate -group I2C /ads1115_reader_tb/DUT/I2C_CONTROLLER/nack
add wave -noupdate -group I2C /ads1115_reader_tb/DUT/I2C_CONTROLLER/state
add wave -noupdate -group I2C /ads1115_reader_tb/DUT/I2C_CONTROLLER/scl_i
add wave -noupdate -group I2C /ads1115_reader_tb/DUT/I2C_CONTROLLER/sda_i
add wave -noupdate -group I2C /ads1115_reader_tb/DUT/I2C_CONTROLLER/clk_cnt
add wave -noupdate -group I2C /ads1115_reader_tb/DUT/I2C_CONTROLLER/scl_hp_cnt
add wave -noupdate -group I2C /ads1115_reader_tb/DUT/I2C_CONTROLLER/rx_ack_bit_to_send
add wave -noupdate -group I2C /ads1115_reader_tb/DUT/I2C_CONTROLLER/byte_to_send
add wave -noupdate -group I2C /ads1115_reader_tb/DUT/I2C_CONTROLLER/sample_ack
add wave -noupdate -group I2C /ads1115_reader_tb/DUT/I2C_CONTROLLER/sda_delay
add wave -noupdate -group I2C /ads1115_reader_tb/DUT/I2C_CONTROLLER/sda_sampled
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1650689349 ps} 0}
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
configure wave -timeline 1
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {1612861704 ps}
