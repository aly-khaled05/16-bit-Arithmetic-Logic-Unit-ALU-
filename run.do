vlib work
vlog Alu.v ALU_TESTBENCH.V
vsim -voptargs=+acc work.ALU_tb
add wave *
run -all