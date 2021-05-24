onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ring_of_fire_tb/DUT/clk
add wave -noupdate /ring_of_fire_tb/DUT/rst_n
add wave -noupdate /ring_of_fire_tb/DUT/rst
add wave -noupdate -radix unsigned -childformat {{/ring_of_fire_tb/DUT/cnt(15) -radix unsigned} {/ring_of_fire_tb/DUT/cnt(14) -radix unsigned} {/ring_of_fire_tb/DUT/cnt(13) -radix unsigned} {/ring_of_fire_tb/DUT/cnt(12) -radix unsigned} {/ring_of_fire_tb/DUT/cnt(11) -radix unsigned} {/ring_of_fire_tb/DUT/cnt(10) -radix unsigned} {/ring_of_fire_tb/DUT/cnt(9) -radix unsigned} {/ring_of_fire_tb/DUT/cnt(8) -radix unsigned} {/ring_of_fire_tb/DUT/cnt(7) -radix unsigned} {/ring_of_fire_tb/DUT/cnt(6) -radix unsigned} {/ring_of_fire_tb/DUT/cnt(5) -radix unsigned} {/ring_of_fire_tb/DUT/cnt(4) -radix unsigned} {/ring_of_fire_tb/DUT/cnt(3) -radix unsigned} {/ring_of_fire_tb/DUT/cnt(2) -radix unsigned} {/ring_of_fire_tb/DUT/cnt(1) -radix unsigned} {/ring_of_fire_tb/DUT/cnt(0) -radix unsigned}} -subitemconfig {/ring_of_fire_tb/DUT/cnt(15) {-height 30 -radix unsigned} /ring_of_fire_tb/DUT/cnt(14) {-height 30 -radix unsigned} /ring_of_fire_tb/DUT/cnt(13) {-height 30 -radix unsigned} /ring_of_fire_tb/DUT/cnt(12) {-height 30 -radix unsigned} /ring_of_fire_tb/DUT/cnt(11) {-height 30 -radix unsigned} /ring_of_fire_tb/DUT/cnt(10) {-height 30 -radix unsigned} /ring_of_fire_tb/DUT/cnt(9) {-height 30 -radix unsigned} /ring_of_fire_tb/DUT/cnt(8) {-height 30 -radix unsigned} /ring_of_fire_tb/DUT/cnt(7) {-height 30 -radix unsigned} /ring_of_fire_tb/DUT/cnt(6) {-height 30 -radix unsigned} /ring_of_fire_tb/DUT/cnt(5) {-height 30 -radix unsigned} /ring_of_fire_tb/DUT/cnt(4) {-height 30 -radix unsigned} /ring_of_fire_tb/DUT/cnt(3) {-height 30 -radix unsigned} /ring_of_fire_tb/DUT/cnt(2) {-height 30 -radix unsigned} /ring_of_fire_tb/DUT/cnt(1) {-height 30 -radix unsigned} /ring_of_fire_tb/DUT/cnt(0) {-height 30 -radix unsigned}} /ring_of_fire_tb/DUT/cnt
add wave -noupdate /ring_of_fire_tb/DUT/led_5
add wave -noupdate -format Analog-Step -height 256 -max 255.0 -radix unsigned /ring_of_fire_tb/DUT/duty_cycle
add wave -noupdate -group SINE_ROM /ring_of_fire_tb/DUT/SINE_ROM/clk
add wave -noupdate -group SINE_ROM /ring_of_fire_tb/DUT/SINE_ROM/addr
add wave -noupdate -group SINE_ROM /ring_of_fire_tb/DUT/SINE_ROM/data
add wave -noupdate -group RESET /ring_of_fire_tb/DUT/RESET/clk
add wave -noupdate -group RESET /ring_of_fire_tb/DUT/RESET/rst_n
add wave -noupdate -group RESET /ring_of_fire_tb/DUT/RESET/rst
add wave -noupdate -group RESET /ring_of_fire_tb/DUT/RESET/sreg
add wave -noupdate -group RESET /ring_of_fire_tb/DUT/RESET/clk
add wave -noupdate -group RESET /ring_of_fire_tb/DUT/RESET/rst_n
add wave -noupdate -group RESET /ring_of_fire_tb/DUT/RESET/rst
add wave -noupdate -group RESET /ring_of_fire_tb/DUT/RESET/sreg
add wave -noupdate -group PWM /ring_of_fire_tb/DUT/PWM/clk
add wave -noupdate -group PWM /ring_of_fire_tb/DUT/PWM/rst
add wave -noupdate -group PWM /ring_of_fire_tb/DUT/PWM/duty_cycle
add wave -noupdate -group PWM -radix unsigned /ring_of_fire_tb/DUT/PWM/pwm_out
add wave -noupdate -group PWM -radix unsigned /ring_of_fire_tb/DUT/PWM/pwm_cnt
add wave -noupdate -group PWM -radix unsigned /ring_of_fire_tb/DUT/PWM/clk_cnt
add wave -noupdate -group PWM /ring_of_fire_tb/DUT/PWM/clk
add wave -noupdate -group PWM /ring_of_fire_tb/DUT/PWM/rst
add wave -noupdate -group PWM /ring_of_fire_tb/DUT/PWM/duty_cycle
add wave -noupdate -group PWM -radix unsigned /ring_of_fire_tb/DUT/PWM/pwm_out
add wave -noupdate -group PWM -radix unsigned /ring_of_fire_tb/DUT/PWM/pwm_cnt
add wave -noupdate -group PWM -radix unsigned /ring_of_fire_tb/DUT/PWM/clk_cnt
add wave -noupdate -group COUNTER /ring_of_fire_tb/DUT/COUNTER/clk
add wave -noupdate -group COUNTER /ring_of_fire_tb/DUT/COUNTER/rst
add wave -noupdate -group COUNTER /ring_of_fire_tb/DUT/COUNTER/count_enable
add wave -noupdate -group COUNTER -radix unsigned /ring_of_fire_tb/DUT/COUNTER/counter
add wave -noupdate -group COUNTER -radix unsigned /ring_of_fire_tb/DUT/COUNTER/counter_i
add wave -noupdate -group COUNTER /ring_of_fire_tb/DUT/COUNTER/clk
add wave -noupdate -group COUNTER /ring_of_fire_tb/DUT/COUNTER/rst
add wave -noupdate -group COUNTER /ring_of_fire_tb/DUT/COUNTER/count_enable
add wave -noupdate -group COUNTER -radix unsigned /ring_of_fire_tb/DUT/COUNTER/counter
add wave -noupdate -group COUNTER -radix unsigned /ring_of_fire_tb/DUT/COUNTER/counter_i
add wave -noupdate /ring_of_fire_tb/led_1
add wave -noupdate /ring_of_fire_tb/led_2
add wave -noupdate /ring_of_fire_tb/led_3
add wave -noupdate /ring_of_fire_tb/led_4
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 3} {645160 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 210
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
WaveRestoreZoom {0 ns} {1470 us}
