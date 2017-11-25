# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog part2.v

#load simulation using mux as the top level simulation module
vsim -L altera_mf_ver display

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}



#TEST PLAN: this part should check: A / B = C -- D
# 1. A < B    2. A = B     3. A > B     4. B = 0
#SO WE CHOOSE: 
#              7/3=2 -- 1  
#              9/9=1 -- 0
#              9/8=1 -- 1
#              6/8=0 -- 6
#              1/0=F -- 1
 

force {clock} 1 0ns , 0 {10ns}  -r 20ns

#reset

force {resetn} 0
force {start} 0
run 40ns

#run

force {resetn} 1
force {start} 1
force {black} 0
force {xy_in} 10#8
force {color_in} 2#001
run 40ns

force {start} 0
force {xy_in} 10#12
run 40ns

force {start} 1
run 40ns

force {start} 0
run 80000ns

#run

force {resetn} 1
force {start} 1
force {black} 0
force {xy_in} 10#0
force {color_in} 2#001
run 40ns

force {start} 0
force {xy_in} 10#0
run 40ns

force {start} 1
run 42000ns

#run black

force {start} 1
force {black} 1
run 42000ns
