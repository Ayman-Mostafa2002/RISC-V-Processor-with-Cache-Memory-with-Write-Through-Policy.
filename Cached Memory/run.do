vlib work 
vlog *.v
vsim -voptargs=+acc work.Cache_tb
add wave *
run -all
