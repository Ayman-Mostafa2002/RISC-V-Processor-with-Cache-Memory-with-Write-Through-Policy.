vlib work 
vlog *.v
vsim -voptargs=+acc work.RISC_tb
add wave *
run -all
