onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group DUT /top_tb/DUT/clk
add wave -noupdate -expand -group DUT /top_tb/DUT/rst_ext
add wave -noupdate -expand -group DUT /top_tb/DUT/uart_tx
add wave -noupdate -expand -group DUT /top_tb/DUT/scl
add wave -noupdate -expand -group DUT /top_tb/DUT/sda
add wave -noupdate -expand -group DUT /top_tb/DUT/rst
add wave -noupdate -expand -group DUT /top_tb/DUT/ready
add wave -noupdate -expand -group DUT /top_tb/DUT/valid
add wave -noupdate -expand -group DUT /top_tb/DUT/x_data
add wave -noupdate -expand -group DUT /top_tb/DUT/y_data
add wave -noupdate -expand -group DUT /top_tb/DUT/send_tdata
add wave -noupdate -expand -group DUT /top_tb/DUT/send_tvalid
add wave -noupdate -expand -group DUT /top_tb/DUT/send_tready
add wave -noupdate -expand -group DUT /top_tb/DUT/clk_counter
add wave -noupdate -expand -group DUT /top_tb/DUT/state
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
WaveRestoreZoom {0 ps} {1 ns}
