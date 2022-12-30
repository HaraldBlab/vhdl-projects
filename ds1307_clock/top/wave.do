onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group top /top_tb/DUT/clk
add wave -noupdate -group top /top_tb/DUT/rst_ext
add wave -noupdate -group top /top_tb/DUT/uart_rx
add wave -noupdate -group top /top_tb/DUT/uart_tx
add wave -noupdate -group top /top_tb/DUT/uart_rx_fifo_full
add wave -noupdate -group top /top_tb/DUT/uart_rx_stop_bit_error
add wave -noupdate -group top /top_tb/DUT/rtcc_scl
add wave -noupdate -group top /top_tb/DUT/rtcc_sda
add wave -noupdate -group top /top_tb/DUT/rst
add wave -noupdate -group top /top_tb/DUT/cmd_tdata
add wave -noupdate -group top /top_tb/DUT/cmd_tvalid
add wave -noupdate -group top /top_tb/DUT/cmd_tready
add wave -noupdate -group top /top_tb/DUT/rd_tdata
add wave -noupdate -group top /top_tb/DUT/rd_tvalid
add wave -noupdate -group top /top_tb/DUT/rd_tready
add wave -noupdate -expand -group i2c_controller /top_tb/DUT/I2C_CONTROLLER/clk
add wave -noupdate -expand -group i2c_controller /top_tb/DUT/I2C_CONTROLLER/rst
add wave -noupdate -expand -group i2c_controller /top_tb/DUT/I2C_CONTROLLER/scl
add wave -noupdate -expand -group i2c_controller /top_tb/DUT/I2C_CONTROLLER/sda
add wave -noupdate -expand -group i2c_controller /top_tb/DUT/I2C_CONTROLLER/cmd_tdata
add wave -noupdate -expand -group i2c_controller /top_tb/DUT/I2C_CONTROLLER/cmd_tvalid
add wave -noupdate -expand -group i2c_controller /top_tb/DUT/I2C_CONTROLLER/cmd_tready
add wave -noupdate -expand -group i2c_controller /top_tb/DUT/I2C_CONTROLLER/rd_tdata
add wave -noupdate -expand -group i2c_controller /top_tb/DUT/I2C_CONTROLLER/rd_tvalid
add wave -noupdate -expand -group i2c_controller /top_tb/DUT/I2C_CONTROLLER/rd_tready
add wave -noupdate -expand -group i2c_controller /top_tb/DUT/I2C_CONTROLLER/nack
add wave -noupdate -expand -group i2c_controller /top_tb/DUT/I2C_CONTROLLER/state
add wave -noupdate -expand -group i2c_controller /top_tb/DUT/I2C_CONTROLLER/clk_cnt
add wave -noupdate -expand -group i2c_controller /top_tb/DUT/I2C_CONTROLLER/scl_hp_cnt
add wave -noupdate -expand -group i2c_controller /top_tb/DUT/I2C_CONTROLLER/scl_i
add wave -noupdate -expand -group i2c_controller /top_tb/DUT/I2C_CONTROLLER/sda_i
add wave -noupdate -expand -group i2c_controller /top_tb/DUT/I2C_CONTROLLER/sda_sampled
add wave -noupdate -expand -group i2c_controller /top_tb/DUT/I2C_CONTROLLER/sda_delay
add wave -noupdate -expand -group i2c_controller /top_tb/DUT/I2C_CONTROLLER/byte_to_send
add wave -noupdate -expand -group i2c_controller /top_tb/DUT/I2C_CONTROLLER/rx_ack_bit_to_send
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {38644280 ns} 0} {{Cursor 3} {1323815 ns} 0}
quietly wave cursor active 2
configure wave -namecolwidth 181
configure wave -valuecolwidth 218
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {5460735 ns}
