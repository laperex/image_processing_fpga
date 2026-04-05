# =============================================================================
# bd_image_processing_wrapper.tcl
# Hook procs called by xviv synthesis for bd_image_processing_wrapper
# Leave a proc body empty if you don't need it.
# =============================================================================

proc report_synth    {} { return 0 }
proc report_place    {} { return 0 }
proc report_route    {} { return 0 }
proc report_netlists {} { return 0 }

proc synth_pre {} {}
proc synth_post {} {}
proc place_post {} {}
proc route_post {} {}
proc bitstream_post {} {}
