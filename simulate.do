# Joshua Arroyo - ModelSim/QuestaSim Simulation Script
# Automatically finds, selects, compiles, and simulates a testbench
# Includes timeout handling

# Step 1: Clear previous work
vlib work
vmap work work

# Step 2: Find all _tb.vhd files in the directory
set testbenches [glob -nocomplain *_tb.vhd]

if {$testbenches eq ""} {
    puts "No testbench files found ending in '_tb.vhd'."
    exit
}

# Step 3: Display available testbenches
puts "Available Testbenches:"
set index 1
foreach tb $testbenches {
    puts "$index) $tb"
    incr index
}

# Step 4: Ask user to choose a testbench
puts -nonewline "Enter the number of the testbench to run: "
flush stdout
gets stdin choice

# Convert choice to a valid index
if {[string is integer -strict $choice] && $choice > 0 && $choice <= [llength $testbenches]} {
    set selected_tb [lindex $testbenches [expr $choice - 1]]
    set entity_name [file rootname [file tail $selected_tb]]

    puts "Compiling and running: $selected_tb"

    # Step 5: Compile and simulate
    vlog $selected_tb
    vsim -novopt work.$entity_name

    # Add waves (optional, remove if not needed)
    add wave -position insertpoint sim:/*

    # Step 6: Run simulation with timeout
    set timeout_limit 1000  ;# Set the timeout limit in nanoseconds
    run $timeout_limit

    # Step 7: Force stop if simulation is still running
    if {[vsim status] == "running"} {
        puts "Simulation exceeded timeout limit ($timeout_limit ns). Stopping simulation."
        quit -force
    }

} else {
    puts "Invalid selection. Exiting."
    exit
}
