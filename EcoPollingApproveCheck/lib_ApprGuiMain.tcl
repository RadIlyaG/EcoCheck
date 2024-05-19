# ***************************************************************************
# ApprovalGui
# ***************************************************************************
proc Gui {} {
  global gaApprGui
  
  set ret 0
  puts "\nApprovalGui"
  wm geometry . $gaApprGui(xy)
  wm resizable . 0 0
  wm title . "ECO/NPI/NOI Verification"
  wm protocol . WM_DELETE_WINDOW {Quit}
  
  set ::rbMode apprNewRel
  set ::appEcAi apprWholeEco
  
  set mainframe [MainFrame .mainframe]
    set gaApprGui(ind_ver) [$mainframe addindicator]
    $gaApprGui(ind_ver) configure -text "1.0"
    
    set tb0 [$mainframe addtoolbar]
    pack $tb0 -fill x
    set bb [ButtonBox $tb0.bbox0 -spacing 1 -padx 5 -pady 5]
    set gaGui(tbRefresh) [$bb add -image [image create photo -file  images/refresh.ico] \
        -takefocus 1 -command {MainEcoPolling} -bd 1 -padx 5 -pady 5 -helptext "Refresh"]		 		 
    pack $bb -side left  -anchor w -padx 2 ;#-pady 3
    # set bb [ButtonBox $tb0.bbox1 -spacing 1 -padx 5 -pady 5]
    # set gaGui(tbClear) [$bb add -image [image create photo -file  images/clear1.ico] \
        # -takefocus 1 -command {} -bd 1 -padx 5 -pady 5 -helptext "Clear the form"]		 		 
    # pack $bb -side left  -anchor w -padx 2 ;#-pady 3
    
    set mf [$mainframe getframe]
  
  pack [TitleFrame $mf.frChooseMode -text "Choose Mode" -bd 2 -relief groove] -padx 2 -pady 2 -fill both
    set fr [$mf.frChooseMode getframe]
    set gaApprGui(rbModeRnA) [radiobutton $fr.rbModeRnA -text "Approve new Released Change" \
        -value apprNewRel -variable ::rbMode -command ToggleListBox] 
    set gaApprGui(rbModeAiA) [radiobutton $fr.rbModeAiA -text "Approve in Advance" \
        -value apprInAdv -variable ::rbMode -command ToggleListBox]
    
    set gaApprGui(frANewListBox) [frame $fr.frANewListBox -bd 0 -relief groove] 
      set fr123 [frame $gaApprGui(frANewListBox).fr123 -bd 2 -relief groove] 
        scrollbar $fr123.yscroll -command {$gaApprGui(lbANew) yview} -orient vertical
        pack   $fr123.yscroll -side right -fill y
        set gaApprGui(lbANew) [listbox $fr123.lbANew -yscrollcommand "$fr123.yscroll set" \
            -height 3 -width 12 -selectmode single]
        bind $gaApprGui(lbANew)  <Double-1> {EcoToHandle} 
        bind $gaApprGui(lbANew)  <ButtonRelease-1> {EcoToHandle} 
        bind $gaApprGui(lbANew)  <<Copy>> {CopyItem %W}  
        pack $gaApprGui(lbANew) -side left -fill both -expand 1 
      grid $fr123 -sticky nswe  
      grid $gaApprGui(rbModeRnA) $gaApprGui(frANewListBox) -padx 2 -pady 0 -sticky nw
      #grid $gaApprGui(rbModeAiA) -padx 2 -pady 0 -sticky nw
    grid $gaApprGui(frANewListBox)  -padx 2 -pady 2 -sticky nswe
          
  pack [TitleFrame $mf.frEco -text "Handled ECO/NPI/NOI" -bd 2 -relief groove] -padx 2 -pady 2 -fill both
    set fr [$mf.frEco getframe]
    set fr1 [frame $fr.fr1]
      set gaApprGui(entEco) [Entry $fr1.entEco]
      set fr345 [frame $fr1.fr345 -bd 2 -relief groove] 
          pack [label $fr345.l1 -text "All Affected Items"]
          scrollbar $fr345.yscroll -command {$gaApprGui(lbAI) yview} -orient vertical
          pack   $fr345.yscroll -side right -fill y
          set gaApprGui(lbAI) [listbox $fr345.lbAI -yscrollcommand "$fr345.yscroll set" \
              -height 6 -width 45 -selectmode single]
          bind $gaApprGui(lbAI)  <Double-1> {CheckAI}  
          bind $gaApprGui(lbAI)  <<Copy>> {CopyItem %W}  
                 
          pack $gaApprGui(lbAI) -side left -fill both -expand 1 
      pack $gaApprGui(entEco) $fr345 -side left -padx 2 -pady 2 -anchor n ; # $butGetAI
      pack configure $fr345 -fill both -expand y
      
      set fr678 [frame $fr1.fr678 -bd 2 -relief groove] 
          pack [label $fr678.l1 -text "Selected Affected Items"]
          scrollbar $fr678.yscroll -command {$gaApprGui(lbSelAI) yview} -orient vertical
          pack   $fr678.yscroll -side right -fill y
          set gaApprGui(lbSelAI) [listbox $fr678.lbSelAI -yscrollcommand "$fr678.yscroll set" \
              -height 6 -width 45 -selectmode single]
          #DynamicHelp::add $gaApprGui(lbSelAI) -text "Click Right Mouse Button to paste copied Item/s"
          bind $gaApprGui(lbSelAI)  <Double-1> {UnCheckAI} 
          bind $gaApprGui(lbSelAI)  <ButtonRelease-3>  {AddAffectedItemsPop %X %Y}   
          bind $gaApprGui(lbSelAI)  <<Paste>> {AddAffectedItems}           
          pack $gaApprGui(lbSelAI) -side left -padx 2 -pady 2 -fill both -expand 1 
      pack configure $fr678 -fill both -padx 2 -pady 2 -expand y
      
    set fr2 [frame $fr.fr2 -bd 2 -relief groove]  
      set gaApprGui(rbApprWholeEco) [radiobutton $fr2.rbApprWholeEco -text "Approve whole ECO/NPI/NFI"\
          -value apprWholeEco -variable ::appEcAi -command ToggleWholeSelected]
      set gaApprGui(rbApprAffInits) [radiobutton $fr2.rbApprAffInits -text "Approve selected Affected Items"\
          -value apprSelItems -variable ::appEcAi -command ToggleWholeSelected]
      pack $gaApprGui(rbApprWholeEco) $gaApprGui(rbApprAffInits) -anchor w -padx 2
    pack $fr1 $fr2 -fill both -padx 2 -pady 2 

  pack [TitleFrame $mf.frVerItems -text "Verified Items" -bd 2 -relief groove] -padx 2 -pady 2 -fill both
    set fr [$mf.frVerItems getframe]
    set fr1 [frame $fr.fr1]
      set itemNameL  [list "Default configuration" "Change in Mechanical parts (FAN, Power supplies...)"]
      lappend itemNameL "Effect on FTI (changing in conf , adding test...)" "SW Version" "Boot Version"
      lappend itemNameL  "CPLD Version" "ATE compatible to FTI"
      foreach itemName $itemNameL {
        set item [string tolower [string range [join $itemName ""] 0 4]]
        set gaApprGui(chb$item) [checkbutton $fr1.chb$item -text $itemName -variable ::verItems$item]
        array set ::gaVerItems [list $item $itemName]
        # pack $gaApprGui(chb$item) -padx 2 -anchor w
        set index [lsearch $itemNameL $itemName]
        grid $gaApprGui(chb$item) -padx 2 -row [expr {$index / 2}] -column [expr {$index % 2}] -sticky w
      }
    pack $fr1 -fill both -padx 2 -pady 2 
 
  # pack [TitleFrame $mf.frApprover -text "Approver" -bd 2 -relief groove] -padx 2 -pady 2 -fill both
    # set fr [$mf.frApprover getframe]
  pack [frame $mf.frApprover  -bd 2 -relief groove] -padx 2 -pady 2 -fill both
    set fr $mf.frApprover
    set lab [Label $fr.lab -text "Appover's Employee Number"]
    set gaApprGui(entAppEmplNumber) [Entry $fr.entAppEmplNumber -justify center -width 10 -state normal -editable 1 ]    
    set but [Button $fr.butSaveNew -text "Approve" -command [list ButApproveGuiEco ] -width 11]
    grid $lab $gaApprGui(entAppEmplNumber) $but -padx 2 -pady 3 -sticky w
    grid configure $but -padx 12
  pack $fr -padx 2 -pady 2 -fill both 
  
  # pack [frame $mf.frBut ] -pady 4 -anchor e
    # pack [Button $mf.frBut.butSaveNew -text "Approve" -command [list ButApproveGuiEco ] -width 11]  -side right -padx 6
    
  pack $mainframe -fill both -expand yes
  ToggleListBox
  ToggleWholeSelected
  
  bind . <F1> {console show}
  bind . <Alt-s> {ToogleVerifyChB 1}
  bind . <Alt-d> {ToogleVerifyChB 0}
  bind . <Alt-a> {ButApproveGuiEco}
  return 0
}

# ***************************************************************************
# AddAffectedItemsPop
# ***************************************************************************
proc AddAffectedItemsPop {x y} {
  global gaApprGui
  #clipboard clear
  if {[winfo exists .popup]} {
    destroy .popup
  }
  menu .popup -tearoff off
  .popup delete 0
  update idletasks
  #.popup add command -label "Add Items to List" -command [list AddAffectedItems]
  .popup add command -label "Clear the List"  -command [list ClearAffectedItems]
  tk_popup .popup $x $y
}
# ***************************************************************************
# AddAffectedItems
# ***************************************************************************
proc AddAffectedItems {} {
  global gaApprGui
  set affectedItems [split [string trim [clipboard get]] ]
  if [llength $affectedItems] {
    foreach ai $affectedItems {
      if [catch {$gaApprGui(lbSelAI) insert end $ai -text $ai} res] {
        puts $res
      }
    }  
  }
}
# ***************************************************************************
# ClearAffectedItems
# ***************************************************************************
proc ClearAffectedItems {} {
  global gaApprGui
  $gaApprGui(lbSelAI) delete 0 end
}

# ***************************************************************************
# ToggleListBox
# ***************************************************************************
proc ToggleListBox {} {
  global gaApprGui 
  puts "\nToggleListBox $::rbMode"
  if {$::rbMode=="apprNewRel"} {     
    #$gaApprGui(entAiA) configure -state disabled
    $gaApprGui(lbANew) configure -state normal
    # grid forget $gaApprGui(frEntAppInAdv)
    # grid $gaApprGui(frANewListBox) -padx 2 -pady 2 -sticky we
    set ret [DbFileExists]
    if {$ret!=0} {return $ret}
    set ret [CheckRnADB]
    if {$ret!=0} {return $ret}
  } elseif {$::rbMode=="apprInAdv"} {
    set ::appEcAi apprSelItems
    $gaApprGui(lbANew) configure -state disabled
    $gaApprGui(entEco) delete 0 end
    $gaApprGui(lbAI) delete 0 end
    $gaApprGui(lbSelAI) delete 0 end
    $gaApprGui(lbANew) selection clear
    #$gaApprGui(entAiA) configure -state normal
    # grid forget $gaApprGui(frANewListBox) 
    # grid x $gaApprGui(frEntAppInAdv) -padx 2 -pady 2 -sticky we
  } 
}
# ***************************************************************************
# DbFileExists
# ***************************************************************************
proc DbFileExists {} {
  if [file exists $::db_file] {
    return 0
  } else {
    set txt "The [file tail $::db_file] file doesn't exist at [file dirname $::db_file]"
    tk_messageBox -icon error  -message $txt -type ok -title "No DB file"
    return -1
  }
}
# ***************************************************************************
# CheckRnADB
# ***************************************************************************
proc CheckRnADB {} {
  global gaApprGui
  sqlite3 dataBase $::db_file
  dataBase timeout 5000
  
  catch {lsort -unique [dataBase eval "Select ECO from ReleasedNotApproved"]} ecos
  puts "ecos:<$ecos>"
  dataBase close
  $gaApprGui(lbANew) delete  0 end
  if [llength $ecos] {
    foreach eco $ecos {
      $gaApprGui(lbANew) insert end $eco
      
    }  
    $gaApprGui(lbANew) configure -height 6 ; #[expr {0+[llength $ecos]}]
  }
  return 0
}
# ***************************************************************************
# EcoToHandle
# ***************************************************************************
proc EcoToHandle {} {
  global gaApprGui
  update
  set indx [$gaApprGui(lbANew) curselection]
  puts "EcoToHandle <$indx>"
  if {$indx!=""} {
    set cell [$gaApprGui(lbANew) get $indx]
    $gaApprGui(entEco) delete 0 end
    $gaApprGui(entEco) insert end $cell
  }
  $gaApprGui(lbAI) delete 0 end
  $gaApprGui(lbSelAI) delete 0 end
  set ret [DbFileExists]
  if {$ret!=0} {return $ret}
  set ret [CheckAIDB]
  if {$ret!=0} {return $ret}
  return $ret
}
# ***************************************************************************
# ButGetAI
# ***************************************************************************
proc ButGetAI {} {
  global gaApprGui
  set ret [DbFileExists]
  if {$ret!=0} {return $ret}
  set ret [CheckAIDB]
  if {$ret!=0} {return $ret}
  return $ret
}
# ***************************************************************************
# CheckAIDB
# ***************************************************************************
proc CheckAIDB {} {
  global gaApprGui
  sqlite3 dataBase $::db_file
  dataBase timeout 5000
  
  set eco [$gaApprGui(entEco) cget -text]
  catch {lsort -unique [dataBase eval {SELECT Unit from ReleasedNotApproved WHERE ECO=$eco}]} units
  #puts "units:<$units>"
  dataBase close
  $gaApprGui(lbAI) delete 0 end
  if [llength $units] {
    foreach unit $units {
      $gaApprGui(lbAI) insert end $unit
    }  
  }
  return 0
}
# ***************************************************************************
# CheckAI
# ***************************************************************************
proc CheckAI {} {
  global gaApprGui
  set indx [$gaApprGui(lbAI) curselection]
  set unit [$gaApprGui(lbAI) get $indx]
  if {[lsearch [$gaApprGui(lbSelAI) get 0 end] $unit]=="-1"} {
    $gaApprGui(lbSelAI) insert end $unit
    $gaApprGui(lbSelAI) see end
  }
}
# ***************************************************************************
# UnCheckAI
# ***************************************************************************
proc UnCheckAI {} {
  global gaApprGui
  set unit [$gaApprGui(lbSelAI) curselection]
  $gaApprGui(lbSelAI) delete $unit
}
# ***************************************************************************
# CopyItem
# ***************************************************************************
proc CopyItem {w} {
  global gaApprGui
  #puts "CopyItem w:<$w>"
  #set w [winfo parent $w]
  set unit [$w curselection] ; #[$gaApprGui(lbAI) curselection]
  clipboard clear
  update idletasks
  clipboard append $unit
}
# ***************************************************************************
# ButCancGuiEco
# ***************************************************************************
proc ButCancGuiEco {} {
  focus .
}
# ***************************************************************************
# ButApproveGuiEco
# ***************************************************************************
proc ButApproveGuiEco {} {
  global gaApprGui
  set ret [Sanity]
  if {$ret!=0} {return $ret}
  
  if {$ret==0} {
    if {$::appEcAi=="apprWholeEco"} {
      set txt "Whole ECO/NPI is going to be approved.\nAre you sure?"
    } else {
      set txt "Just selected items are going to be approved.\nAre you sure?"
    }
    set res [DialogBox -title "Warning" -text $txt -icon /images/info -type "Yes No"]
    if {$res=="No"} {
      set ret -1
    }
  }
  if {$ret==0} {  
    set ret [MoveEcoFromRNAtoRA]
  }
  if {$ret==0} {
    DialogBox -title "Approve done" -text "[$gaApprGui(entEco) cget -text] approved successfully" -icon /images/info
    ToggleListBox
    ToogleVerifyChB 0
    if {$::rbMode=="apprNewRel"} { 
      if {$::appEcAi=="apprWholeEco"} {
        $gaApprGui(entEco) configure -text ""
      } elseif {$::appEcAi=="apprSelItems"} {
      
      }
    }
  }  
}
# ***************************************************************************
# ButSaveGuiEco
# ***************************************************************************
proc ButSaveGuiEco {} {
  ButCancGuiEco 
}  
# ***************************************************************************
# MoveEcoFromRNAtoRA
# ***************************************************************************
proc MoveEcoFromRNAtoRA {} {
  global gaApprGui
  
  set ret [DbFileExists]
  if {$ret!=0} {return $ret}
  
  if {$::rbMode=="apprNewRel"} { 
    set aiaFlag "no"
  } elseif {$::rbMode=="apprInAdv"} { 
    set aiaFlag "yes"
  }  
  set apprDate [clock format [clock seconds] -format "%d/%m/%Y %H:%M:%S"]
  
  sqlite3 dataBase $::db_file
  dataBase timeout 5000
  
  set eco [$gaApprGui(entEco) cget -text]
  
  if {$::rbMode=="apprNewRel"} { 
    if {$::appEcAi=="apprWholeEco"} {
      catch {dataBase eval {SELECT * from ReleasedNotApproved WHERE ECO=$eco}} ecoData
      after 1000
      catch {dataBase eval {DELETE from ReleasedNotApproved WHERE ECO=$eco}} delres
      puts "delres:<$delres>"      
      $gaApprGui(lbAI) delete 0 end
    } elseif {$::appEcAi=="apprSelItems"} {
      set selectedItems [$gaApprGui(lbSelAI) get 0 end] ; set where ""
      foreach selItem $selectedItems {
        append where " Unit = \'$selItem\' OR"
      }
      set where [string trimright $where " OR"]
      puts "where:<$where>"  
      catch {dataBase eval "SELECT * from ReleasedNotApproved WHERE ECO=\'$eco\' AND ($where)"} ecoData
      after 1000
      catch {dataBase eval "DELETE from ReleasedNotApproved WHERE ECO=\'$eco\' AND ($where)"} delres
      puts "delres:<$delres>"
    }
  } elseif {$::rbMode=="apprInAdv"} { 
    set selectedItems [$gaApprGui(lbSelAI) get 0 end]
    foreach selItem $selectedItems {
       lappend ecoData $eco $selItem $apprDate
    } 
  } 
  puts "ecoData:<$ecoData>"
  
  foreach {eco unit date} $ecoData {
    if {$::rbMode=="apprInAdv"} {
      set date $apprDate
    }
      
    append values "(\'$eco\', \'$unit\', \'$date\', \'$::apprName\', \'$aiaFlag\', \'$apprDate\'),"
  }
  set values [string trimright $values ","]
  puts <$values>
  catch {dataBase eval "INSERT INTO ReleasedApproved VALUES $values"} res
  puts "res:<$res>"
  dataBase close
  
  $gaApprGui(lbSelAI) delete 0 end
  return 0  
}
# ***************************************************************************
# Sanity
# ***************************************************************************
proc Sanity {} {
  global gaApprGui
  foreach txt [glob -nocomplain  *.txt] {
    catch {file delete $txt}
  }
  set eco [$gaApprGui(entEco) cget -text]
  if {$eco==""} {
    tk_messageBox -title "Sanity check" -icon error -type ok \
      -message "No ECO/NPI/NOI to approve"
    focus -force  $gaApprGui(entEco)
    return -1
  }
  
  set selectedItems [$gaApprGui(lbSelAI) get 0 end]
  if {$::appEcAi=="apprSelItems" && $selectedItems==""} {
    tk_messageBox -title "Sanity check" -icon error -type ok \
      -message "No Affected Items to approve"
    focus -force  $gaApprGui(lbAI)
    return -1
  }
  
  set empId [$gaApprGui(entAppEmplNumber) cget -text]
  if {$empId==""} {
    tk_messageBox -title "Sanity check" -icon error -type ok \
      -message "No Approver's Emploee Number"
    focus -force  $gaApprGui(entAppEmplNumber)
    return -1
  }
  set ret [GetOperator $empId]
  if {$ret=="-1"} {return $ret}
  set ::apprName $ret
  
  set notCheckedOut [list]
  foreach item [array names ::gaVerItems] {
    set itemName $::gaVerItems($item)
    set chbState [set ::verItems$item]
    if !$chbState {
      lappend notCheckedOut $itemName
    }
    puts "item:<$item> itemName:<$itemName> chbState:<$chbState>"
  }
  if [llength $notCheckedOut] {
    tk_messageBox -title "Sanity check" -icon error -type ok \
      -message "Not all Verified Items are checked"
    focus -force  $gaApprGui(lbAI)
    return -1
  }
  
  return 0
}
# ***************************************************************************
# GetOperator
# ***************************************************************************
proc GetOperator {empId} {
  if {[string length $empId]==6  && [string is digit $empId]} {
    ## the empId is EmpNumb
    set empName [CheckOperInDB $empId]
    if {$empName!=""} {
      ## the name come fron DB
      set gaSet(operatorID) $empId
      return $empName
    }
    set empName [GetOperRad $empId]
    if {[regexp {Not[\s\w]+\!} $empName]} {
      ## try again
      set te "$empId\n$empName"  
    } else {
      AddOperDB $empId $empName
      set gaSet(operatorID) $empId
      return $empName
    }
  } else {
    ## try again
    set te "$empId\nEntry is not valid\nTry again"
  }
  tk_messageBox -title "Sanity check" -icon error -type ok -message $txt
  focus -force  $gaApprGui(entAppEmplNumber)
  return -1
}
# ***************************************************************************
# ChechOperInDB
# ***************************************************************************
proc CheckOperInDB {empId} {
  #puts "ChechOperInDB $empId"
  package require sqlite3
  sqlite3 dataBase [pwd]/operDB.db 
  dataBase timeout 5000
    
  set res [dataBase eval {SELECT name FROM sqlite_master WHERE type='table' AND name='tbl'}]
  if {$res==""} {
    dataBase eval {CREATE TABLE tbl(EmpID, EmpName)}
  }
  
  set cell [dataBase eval "select EmpName from tbl where EmpID glob $empId"]
  dataBase close
  
  set empName ""
  foreach val $cell {
    foreach {a b c d} $val {
      set empName [concat $a $b $c $d] 
    }
  }
  puts "CheckOperInDB <$empId> <$empName>"
  return $empName
}
# ***************************************************************************
# AddOperDB
# ***************************************************************************
proc AddOperDB {empId empName} {
  sqlite3 dataBase [pwd]/operDB.db
  dataBase timeout 5000
  dataBase eval {INSERT INTO tbl VALUES($empId,$empName)}
  dataBase close 
}
# ***************************************************************************
# GetOperRad
# ***************************************************************************
proc GetOperRad {empId} {
  #puts "GetOperRad $gn $empId" ; update
  if {![file exists $::RadAppsPath/GetEmpName.exe]} {
    tk_messageBox -type ok -icon error -message "GetEmpName.exe doesn't exist"
    return -1  
  }
  if {![file exists $::RadAppsPath/GetEmpName.prd]} {
    tk_messageBox -type ok -icon error -message "GetEmpName.prd doesn't exist"
    return -1  
  }
  catch {exec $::RadAppsPath/GetEmpName.exe $empId} res
  #puts "ti:<$ti> res:<$res>"
  if {$res!=""} {
    tk_messageBox -type ok -icon error -message "Result of GetEmpName.exe $empId \n $res"
    return -1  
  }
  if {![file exists $::RadAppsPath/$empId.txt]} {
    tk_messageBox -type ok -icon error -message "$empId.txt doesn't exist"
    return -1  
  }
  set id [open $::RadAppsPath/$empId.txt]
  set empName [read $id]
  close $id
  set empName [string trim $empName] 
  puts "GetOperRad $empId $empName" ; update
  after 200 "catch {file delete -force $::RadAppsPath/$empId.txt} res"
  return $empName 
}

# ***************************************************************************
# MyTime
# ***************************************************************************
proc MyTime {} {
  return [clock format [clock seconds] -format "%Y.%m.%d-%H.%M.%S"]
}

# ***************************************************************************
# SaveInit
# ***************************************************************************
proc SaveInit {} {
  global gaApprGui  
  set id [open init.tcl w]
  puts $id "set gaApprGui(xy) +[winfo x .]+[winfo y .]"
  close $id   
}
#***************************************************************************
#** Quit
#***************************************************************************
proc Quit {} {
  SaveInit
  RLSound::Play information
  set ret [DialogBox -title "Confirm exit"\
      -type "yes no" -icon images/question -aspect 2000\
      -text "Are you sure you want to close the application?"]
  if {$ret=="yes"} {exit}
}

# ***************************************************************************
# ToggleWholeSelected
# ***************************************************************************
proc ToggleWholeSelected {} {
  global gaApprGui  
  set actFG SystemButtonText
  set actBG SystemWindow 
  set non_actFG gray
  set non_actBG LightCyan3 
  if {$::appEcAi=="apprWholeEco"} {
    $gaApprGui(lbAI)    configure -foreground $actFG -background $actBG
    $gaApprGui(lbSelAI) configure -foreground $non_actFG -background $non_actBG
    focus $gaApprGui(lbAI)
  } else {
    $gaApprGui(lbAI)    configure -foreground $non_actFG -background $non_actBG
    $gaApprGui(lbSelAI) configure -foreground $actFG -background $actBG
    focus $gaApprGui(lbSelAI)
  }
}
# ***************************************************************************
# ToogleVerifyChB
# ***************************************************************************
proc ToogleVerifyChB {state} {
  foreach item [array names ::gaVerItems] {
      set ::verItems$item $state
   }
    
}