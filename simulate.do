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
    set entity_name [string range $selected_tb 0 [expr [string length $selected_tb] - 5]]  ;# Extract base name without extension
    set design_entity_name [string range $selected_tb 0 [expr [string length $selected_tb] - 8]]  ;# Extract base name without extension and _tb
    set design_file "$design_entity_name.vhd"  ;# Expected design file name

    puts "Compiling and running: $selected_tb"

    # Step 5: Compile the design file and the testbench (if design file exists)
    if {[file exists $design_file]} {
        puts "Compiling design file: $design_file"
        vcom -reportprogress 300 -work work $design_file
    } else {
        puts "Warning: Design file '$design_file' not found!"
    }

    puts "Compiling testbench file: $selected_tb"
    vcom -reportprogress 300 -work work $selected_tb

    # Step 6: Simulate the selected testbench
    puts "Simulating the selected entity: $entity_name"
    vsim work.$entity_name

    # Step 7: Run simulation
    puts "Adding waves"
    add wave -position insertpoint sim:/*

} else {
    puts "Invalid selection. Exiting."
    exit
}
