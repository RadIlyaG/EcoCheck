package require sqlite3
set db_file     //prod-svm1/tds/Temp/SQLiteDB/EcoCheck.db
set ecoFilePath //prod-svm1/tds/Temp/SQLiteDB/EcoNoiNpi
package require json
#console show


# ***************************************************************************
# MainEcoPolling
# ***************************************************************************
proc MainEcoPolling {} {
  set ret [ReadEcoFiles]
  
  return $ret
}
# ***************************************************************************
# AddToLog
# ***************************************************************************
proc AddToLog {txt} {
  set id [open $::log a+]
  puts $id "[clock format [clock second] -format %Y/%m/%d_%H:%M:%S] $txt"
  close $id
}
# ***************************************************************************
# ReadEcoFiles
# ***************************************************************************
proc ReadEcoFiles {} {
  set ::log c:/logs/EcoPollingLog.txt
  if ![file exists c:/logs] {
    file mkdir c:/logs
  }
  if ![file exists $::ecoFilePath] {
    tk_messageBox -type ok -title "No path" -message "The \'$::ecoFilePath\' doesn't exist"
    set ret -1
  } else {
    set ret 0
  }
  if {$ret==0} {
    set ecoFiles [lsort -dict [glob -nocomplain -directory $::ecoFilePath \[CN\]*]]
    if [llength $ecoFiles] {
      foreach ecoFile $ecoFiles {
        set di [set ret [ReadEcoFile $ecoFile] ]
        puts "ret of ReadEcoFile: <$ret>"        
        if {$ret=="-1"} {break}  
        set ret [EcoData2DB $ecoFile $di]  
        puts "ret of EcoData2DB: <$ret>"  
        if {$ret=="emailAndDelete"} {
          ## ECO was added to ReleasedNotApproved
          set ret [SendEmail $ecoFile]   
          puts "ret of SendEmail: <$ret>"            
        }  
        set ret [DeleteEcoFile $ecoFile]  
        puts "ret of DeleteEcoFile: <$ret>"    
        AddToLog "$ecoFile"        
      }
    } else {
      puts "No new ECO files"
      AddToLog "No new ECO files"
    }
    
  }
  AddToLog "Done"
  return $ret
}
# ***************************************************************************
# ReadEcoFile
# ***************************************************************************
proc ReadEcoFile {ecoFile} {
  puts "\nReadEcoFile $ecoFile"
  set ecoTail [file tail $ecoFile]
  set ecoFileName [lindex [split $ecoTail .] 0]
  if [catch {open $ecoFile r+} id] {
    set txt "$id\n\nCan't open file \'$ecoFile\'"
    tk_messageBox -type ok -title "Can't open file \'$ecoTail\'" -message $txt
    set ::gMessage $txt
    return -1
  } else {  
    set ret 0
    while {[gets $id line] >= 0 } {
      set line [string trim $line]
      if {[string length $line] !=0} {
        append body $line
      }  
    }  
    close $id
    puts "ecoFile:<$ecoFile> body:<$body>" 
    
    set asadict [::json::json2dict $body]
    foreach {name wotsit} $asadict {
      puts "<$name> <$wotsit> [llength $wotsit]"
      dict set di $name $wotsit
      # if {[llength $wotsit]==1} {
        # puts "1 $name $wotsit"
        # dict set di $name $wotsit
      # } else {
        # foreach {par val} [lindex $wotsit 0] {
          # puts "2 $par $val"
          # dict set di $par $val
        # }
      # }
    }
  }
  if [info exist di] {
    return $di
  } else {
    return -1
  }
}
# ***************************************************************************
# EcoData2DB
# ***************************************************************************
proc EcoData2DB {ecoFile di} {
  puts "\nEcoData2DB $ecoFile $di"
  set ecoTail [file tail $ecoFile]
  set ecoFileName [lindex [split $ecoTail .] 0]
  #set ecoUnits [lsort -dictionary [set ::a${ecoFileName}(AI)]]
  set ecoUnits [lsort -dictionary [dict get $di "AffectedItems"]]
  puts "EcoData2DB ecoUnits:<$ecoUnits>"
  
  ## meantime all products/units, mentioned in YZ' file, should be inserted to ReleasedNotApproved
  set initsToReleasedNotApproved $ecoUnits
    
  sqlite3 dataBase $::db_file
  dataBase timeout 5000
  
  # ## create list of products/units that mentioned in YZ' file, exist in ReleasedApproved and have ApprInAdv = 'no'
  # ## such unit must be inserted to ReleasedNotApproved
  # catch {dataBase eval {SELECT Unit from ReleasedApproved WHERE (ECO = $ecoFileName AND ApprInAdv = 'no')}} notAiAunits
  # set notAiAunits [lsort -dictionary $notAiAunits]
  # puts "notAiAunits:<$notAiAunits>"
  
  ## create list of products/units that mentioned in YZ' file, exist in ReleasedApproved and have ApprInAdv = 'yes'
  ## all of units from this list will not insert to ReleasedNotApproved
  catch {dataBase eval {SELECT Unit from ReleasedApproved WHERE (ECO = $ecoFileName AND ApprInAdv = 'yes')}} yesAiAunits
  set yesAiAunits [lsort -dictionary $yesAiAunits]
  puts "yesAiAunits:<$yesAiAunits>"
  
  # if 0 {
  # set initsToReleasedNotApproved ""
  # foreach unit $ecoUnits {
    # if {[lsearch $notAiAunits $unit]!="-1"} {
      # lappend initsToReleasedNotApproved $unit
    # }    
  # }
  # foreach unit $ecoUnits {
    # if {[lsearch $yesAiAunits $unit]=="-1"} {
      # lappend initsToReleasedNotApproved $unit
    # }    
  # }
  # set initsToReleasedNotApproved [lsort -unique $initsToReleasedNotApproved]
  # }
  
  ## remove from final list all ApprovedInAnvance products/units
  foreach ecoUnit $ecoUnits {
    foreach yesAiAunit $yesAiAunits {
      if {$ecoUnit==$yesAiAunit} {
        set indx [lsearch $initsToReleasedNotApproved $yesAiAunit]
        set initsToReleasedNotApproved [lreplace $initsToReleasedNotApproved $indx $indx]
      }
    }
  }  
  puts "initsToReleasedNotApproved:<$initsToReleasedNotApproved>"
  
  ## add products/units to ReleasedNotApproved
  foreach unit $initsToReleasedNotApproved {
    #set number [set ::a${ecoFileName}(number)]
    set number [dict get $di "Change Number"]
    #set relDate [set ::a${ecoFileName}(releise_date)]
    set relDate [dict get $di "Change release date"]
    if [catch {dataBase eval {INSERT INTO ReleasedNotApproved VALUES($number,$unit,$relDate)}} res] {
      puts "res INSERT INTO ReleasedNotApproved $unit: <$res>"
    }
    
  }
  dataBase close
  
  if [llength $initsToReleasedNotApproved] {
    set ret emailAndDelete
  } else {
    set ret justDelete
  }
  return $ret 
}  

# ***************************************************************************
# SendEmail
# ***************************************************************************
proc SendEmail {ecoFile} {
  set ecoFileName [lindex [split [file tail $ecoFile] .] 0]
  puts "\nSendEmail $ecoFileName"
  return 0
}
# ***************************************************************************
# DeleteEcoFile
# ***************************************************************************
proc DeleteEcoFile {ecoFile} {
  set ecoFileNew _[file tail $ecoFile]
  set ecoFilePathNew [file join [file dirname $ecoFile] $ecoFileNew]
  puts "\nDeleteEcoFile $ecoFile $ecoFilePathNew"
  file rename -force $ecoFile $ecoFilePathNew
  return 0
}

if {[lindex $argv 0]=="Run"} {
  MainEcoPolling
  exit
}  