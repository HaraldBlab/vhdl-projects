# Usage: do run.do [duration]
# Example: do run.do 15 sec

variable tbEnt "top_tb"
variable tbLib "work"

# 0 = Note  1 = Warning  2 = Error  3 = Failure  4 = Fatal
variable BreakOnAssertion 3

# Don't show base (7'h, 32'd, etc.) in waveform
quietly radix noshowbase

# Collect command line arguments $1 to $9
proc collectCmdLineArgs {} {
  set cl_args ""
  for {set i 1} {$i < 10} {incr i} {
    global $i
    if {[info exists $i]} {
      set cl_args [subst "$cl_args \$$i"]
    }
  }
  return $cl_args
}

# Load the  wave script if it exists
proc loadWave {} {
  if {[file exists wave.do]} {
    do wave.do
  }
}

# If the design already is loaded
if {[runStatus] != "nodesign" && [find instances -bydu -nodu $tbEnt] == "/$tbEnt"} {

  # Restart the simulation
  restart -force

} else {

  # Start a new simulation
  vsim -gui -onfinish stop -msgmode both $tbLib.$tbEnt
  loadWave
}

# If the wave window is not open
if {[string first ".wave" [view]] == -1} {
  loadWave
}

# Save the signal history, even before adding them to the
# waveform. This slows down the simulation for large designs,
# but it allows us to add signals to the waveform
# without restarting the simulation after adding them.
log * -r

# Run the testbench
run [collectCmdLineArgs]