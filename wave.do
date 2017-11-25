# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog random.v

#load simulation using mux as the top level simulation module
vsim Random16

#log all signals and add some signals to waveform window
# add wave {/*} would add all items in top level simulation module
add wave {/*}

force {clock} 1 0ns , 0 {10ns}  -r 20ns

#reset

force {resetn} 0
run 40ns

#run

force {resetn} 1
run 5200ns