## source \\\\prod-svm1\\tds\\Temp\\SQLiteDB\\EcoNoiNpi\\lib_EcoCheck.tcl
console show
package require sqlite3
set db_file \\\\prod-svm1\\tds\\Temp\\SQLiteDB\\EcoCheck.db

# ***************************************************************************
# DbFileExists
# ***************************************************************************
proc DbFileExists {} {
  if [file exists $::db_file] {
    return 0
  } else {
    return "The [file tail $::db_file] file doesn't exist at [file dirname $::db_file]"
  }
}

# ***************************************************************************
# CheckDB
# ***************************************************************************
proc CheckDB {unit} {
  sqlite3 dataBase $::db_file
  dataBase timeout 5000
  
  set res [lsort -unique [dataBase eval "Select ECO from ReleasedNotApproved where Unit = \'$unit\'"]]
  #puts "res:<$res>"
  if {$res==""} {
    set res 0
  }

  dataBase close
  return $res
}

proc Main {unit} {
  set ret [DbFileExists]
  if {$ret!=0} {return $ret}
  
  set ret [CheckDB $unit]
  if {$ret!=0} {
    foreach item $ret {
      append lis  "$item, "
    }
    set lis [string trimright $lis " ,"]
    if {[llength $lis]==1} {
      set verb "was"
    } else {
      set verb "were"
    }
    set txt "The following change/s for \'$unit\' $verb released:\n\n$lis\n\nConsult with your team Leader"
    tk_messageBox -message $txt -type ok -icon error -title "Unapproved changes"
    set ret $txt
  } 
  return $ret  
}

