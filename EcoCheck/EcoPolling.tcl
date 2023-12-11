set ecoFilePath //prod-svm1/tds/Temp/SQLiteDB/EcoNoiNpi

proc MainEcoPolling {} {
  set ret [ReadEcoFiles]
  
  return $ret
}
proc ReadEcoFiles {} {
  if ![file exists $::ecoFilePath] {
    tk_messageBox -type ok -title "No path" -message "The \'$::ecoFilePath\' doesn't exist"
    set ret -1
  } else {
    set ret 0
  }
  if {$ret==0} {
    set ecoFiles [lsort -dict [glob -directory $::ecoFilePath \[CN\]*]]
    if [llength $ecoFiles] {
      foreach ecoFile $ecoFiles {
        set ret [ReadEcoFile $ecoFile]  
        if {$ret!=0} {break}        
      }
    }
  }
  return $ret
}
proc ReadEcoFile {ecoFile} {
  set ecoTail [file tail $ecoFile]
  if [catch {open $ecoFile r+} id] {
    set txt "$id\n\nCan't open file \'$ecoFile\'"
    tk_messageBox -type ok -title "Can't open file \'$ecoTail\'" -message $txt
    return $txt
  } else {  
    set ret 0
    while {[gets $id line] >= 0 } {
      set line [string trim $line]
      if {[string length $line] !=0} {
        lappend lines $line
      }  
    }  
    close $id
    puts "ecoFile:<$ecoFile> lines:<$lines>"    
  }
  return $ret
}