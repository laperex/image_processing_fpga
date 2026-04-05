# =============================================================================
# bd_image_processing_1.0.tcl
# Hook procs called by xviv create-bd / edit-bd for bd_image_processing
# =============================================================================
set ::_bd_design_tcl [file join [file dirname [info script]] "bd_image_processing.tcl"]

proc bd_design_config { parentCell } {
	global _bd_design_tcl

	if {[file exists $_bd_design_tcl]} {
		puts "INFO: Sourcing exported BD TCL - $_bd_design_tcl"
		source $_bd_design_tcl

		xviv_refresh_bd_addresses
		validate_bd_design
		save_bd_design
		exit 0

	} else {
		puts "INFO: No exported BD TCL found at $_bd_design_tcl"
		puts "INFO: Opening GUI for interactive design."
		puts "INFO: When done, run:  xviv export-bd --bd bd_image_processing"
		start_gui
	}
}
