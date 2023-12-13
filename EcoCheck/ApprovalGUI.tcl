console show
package require http
package require base64
package require BWidget
package require sqlite3
set db_file \\\\prod-svm1\\tds\\Temp\\SQLiteDB\\EcoCheck.db

# ***************************************************************************
# ApprovalGui
# ***************************************************************************
proc ApprovalGui {} {
  global gMessage gaGui
  
  set ret 0
  puts "\nApprovalGui"
  
 
  wm resizable . 0 0
  wm title . "ECO/NPI/NOI Verification"
  
  set ::rbMode rna
  set ::appEcAi awe
  
  pack [TitleFrame .frChooseMode -text "Choose Mode" -bd 2 -relief groove] -padx 2 -pady 2 -fill both
    set fr [.frChooseMode getframe]
    set gaGui(rbModeRnA) [radiobutton $fr.rbModeRnA -text "Approve new Released Change" \
        -value rna -variable ::rbMode -command ToggleListBox] 
    set gaGui(rbModeAiA) [radiobutton $fr.rbModeAiA -text "Approve in Advance" \
        -value aia -variable ::rbMode -command ToggleListBox]
    
    set gaGui(frANewListBox) [frame $fr.frANewListBox -bd 0 -relief groove] 
      set fr123 [frame $gaGui(frANewListBox).fr123 -bd 2 -relief groove] 
        scrollbar $fr123.yscroll -command {$gaGui(lbANew) yview} -orient vertical
        pack   $fr123.yscroll -side right -fill y
        set gaGui(lbANew) [ListBox $fr123.lbANew -yscrollcommand "$fr123.yscroll set" \
            -height 3 -width 10 -selectmode single]
        bind $gaGui(lbANew)  <Double-1> {EcoToHandle} 
        #grid  $gaGui(lbANew) $fr123.yscroll -sticky nw  -padx 2 -pady 2  
        pack $gaGui(lbANew) -side left -fill both -expand 1 
      grid $fr123 -sticky nswe  
    # set gaGui(frEntAppInAdv) [frame $fr.frEntAppInAdv -bd 0 -relief groove] 
      # set gaGui(entAiA) [Entry $gaGui(frEntAppInAdv).entAiA]
      # grid  $gaGui(entAiA)  -sticky n
      grid $gaGui(rbModeRnA) $gaGui(frANewListBox) -padx 2 -pady 0 -sticky nw
      grid $gaGui(rbModeAiA) -padx 2 -pady 0 -sticky nw
    grid $gaGui(frANewListBox)  -padx 2 -pady 2 -sticky nswe ; #$gaGui(frEntAppInAdv)
          
  pack [TitleFrame .frEco -text "Handled ECO/NPI/NOI" -bd 2 -relief groove] -padx 2 -pady 2 -fill both
    set fr [.frEco getframe]
    set fr1 [frame $fr.fr1]
      set gaGui(entEco) [Entry $fr1.entEco]
      #set butGetAI [Button $fr1.butGetAI -text "Get Affected Items" -command ButGetAI]
      set fr345 [frame $fr1.fr345 -bd 2 -relief groove] 
          pack [label $fr345.l1 -text "All Affected Items"]
          scrollbar $fr345.yscroll -command {$gaGui(lbAI) yview} -orient vertical
          pack   $fr345.yscroll -side right -fill y
          set gaGui(lbAI) [ListBox $fr345.lbAI -yscrollcommand "$fr345.yscroll set" \
              -height 6 -width 20 -selectmode single]
          bind $gaGui(lbAI)  <Double-1> {CheckAI}     
          pack $gaGui(lbAI) -side left -fill both -expand 1 
      pack $gaGui(entEco) $fr345 -side left -padx 2 -pady 2 -anchor n ; # $butGetAI
      pack configure $fr345 -fill both -expand y
      
      set fr678 [frame $fr1.fr678 -bd 2 -relief groove] 
          pack [label $fr678.l1 -text "Selected Affected Items"]
          scrollbar $fr678.yscroll -command {$gaGui(lbSelAI) yview} -orient vertical
          pack   $fr678.yscroll -side right -fill y
          set gaGui(lbSelAI) [ListBox $fr678.lbSelAI -yscrollcommand "$fr678.yscroll set" \
              -height 6 -width 20 -selectmode single]
          bind $gaGui(lbSelAI)  <Double-1> {UnCheckAI}    
          pack $gaGui(lbSelAI) -side left -padx 2 -pady 2 -fill both -expand 1 
      pack configure $fr678 -fill both -padx 2 -pady 2 -expand y
      
    set fr2 [frame $fr.fr2 -bd 2 -relief groove]  
      set gaGui(rbApprWholeEco) [radiobutton $fr2.rbApprWholeEco -text "Approve whole ECO/NPI/NFI"\
          -value awe -variable ::appEcAi]
      set gaGui(rbApprAffInits) [radiobutton $fr2.rbApprAffInits -text "Approve selected Affected Items"\
          -value aai -variable ::appEcAi]
      pack $gaGui(rbApprWholeEco) $gaGui(rbApprAffInits) -anchor w -padx 2
    pack $fr1 $fr2 -fill both -padx 2 -pady 2 

  pack [TitleFrame .frVerItems -text "Verified Items" -bd 2 -relief groove] -padx 2 -pady 2 -fill both
    set fr [.frVerItems getframe]
    set fr1 [frame $fr.fr1]
      foreach item [list Thing1 Thing2 Thing3 Thing4] {
        set gaGui(chb$item) [checkbutton $fr1.chb$item -text $item -variable ::verItems$item]
        pack $gaGui(chb$item) -padx 2 -anchor w
      }
    pack $fr1 -fill both -padx 2 -pady 2 
 
  pack [TitleFrame .frApprover -text "Approver" -bd 2 -relief groove] -padx 2 -pady 2 -fill both
    set fr [.frApprover getframe]
    set lab [Label $fr.lab -text "Appover's Empl. Number"]
    set gaGui(entAppEmplNumber) [Entry $fr.entAppEmplNumber -justify center -width 10 -state normal -editable 1 ]
    grid $lab $gaGui(entAppEmplNumber) -padx 2 -pady 3 -sticky ew
  
  pack [frame .frBut ] -pady 4 -anchor e
    pack [Button .frBut.butCanc -text Cancel -command [list ButCancGuiEco ] -width 7] -side right -padx 6
    pack [Button .frBut.butSaveNew -text "Save & New" -command [list ButSaveNewGuiEco ] -width 11]  -side right -padx 6
    pack [Button .frBut.butSave -text "Save & Close" -command [list ButSaveGuiEco ] -width 13]  -side right -padx 6
   
  ToggleListBox
  return gMessage
}

# ***************************************************************************
# ToggleListBox
# ***************************************************************************
proc ToggleListBox {} {
  global gaGui 
  puts "\nToggleListBox $::rbMode"
  if {$::rbMode=="rna"} {     
    #$gaGui(entAiA) configure -state disabled
    $gaGui(lbANew) configure -state normal
    # grid forget $gaGui(frEntAppInAdv)
    # grid $gaGui(frANewListBox) -padx 2 -pady 2 -sticky we
    set ret [DbFileExists]
    if {$ret!=0} {return $ret}
    set ret [CheckRnADB]
    if {$ret!=0} {return $ret}
  } elseif {$::rbMode=="aia"} {
    $gaGui(lbANew) configure -state disabled
    $gaGui(entEco) delete 0 end
    $gaGui(lbAI) delete [$gaGui(lbAI) items]
    $gaGui(lbANew) selection clear
    #$gaGui(entAiA) configure -state normal
    # grid forget $gaGui(frANewListBox) 
    # grid x $gaGui(frEntAppInAdv) -padx 2 -pady 2 -sticky we
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
  global gaGui
  sqlite3 dataBase $::db_file
  dataBase timeout 5000
  
  catch {lsort -unique [dataBase eval "Select ECO from ReleasedNotApproved"]} ecos
  puts "ecos:<$ecos>"
  dataBase close
  $gaGui(lbANew) delete [$gaGui(lbANew) items]
  if [llength $ecos] {
    foreach eco $ecos {
      $gaGui(lbANew) insert end $eco -text $eco
    }  
  }
  return 0
}

# ***************************************************************************
# EcoToHandle
# ***************************************************************************
proc EcoToHandle {} {
  global gaGui
  set cell [$gaGui(lbANew) curselection]
  $gaGui(entEco) delete 0 end
  $gaGui(entEco) insert end $cell
  $gaGui(lbAI) delete [$gaGui(lbAI) items]
  $gaGui(lbSelAI) delete [$gaGui(lbSelAI) items]
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
  global gaGui
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
  global gaGui
  sqlite3 dataBase $::db_file
  dataBase timeout 5000
  
  set eco [$gaGui(entEco) cget -text]
  catch {lsort -unique [dataBase eval {SELECT Unit from ReleasedNotApproved WHERE ECO=$eco}]} units
  #puts "units:<$units>"
  dataBase close
  $gaGui(lbAI) delete [$gaGui(lbAI) items]
  if [llength $units] {
    foreach unit $units {
      $gaGui(lbAI) insert end $unit -text $unit
    }  
  }
  return 0
}

# ***************************************************************************
# CheckAI
# ***************************************************************************
proc CheckAI {} {
  global gaGui
  set unit [$gaGui(lbAI) curselection]
  #puts "$unit [$gaGui(lbAI) exists $unit] [$gaGui(lbAI) items]"
  if ![$gaGui(lbSelAI) exists $unit] {
    $gaGui(lbSelAI) insert end $unit -text $unit
    $gaGui(lbSelAI) see $unit

  }
}
# ***************************************************************************
# UnCheckAI
# ***************************************************************************
proc UnCheckAI {} {
  global gaGui
  set unit [$gaGui(lbSelAI) curselection]
  $gaGui(lbSelAI) delete $unit
}
# ***************************************************************************
# ButCancGuiEco
# ***************************************************************************
proc ButCancGuiEco {} {
  global gMessage
  
  focus .
  
  set gMessage "Cancel"
}
# ***************************************************************************
# ButSaveNewGuiEco
# ***************************************************************************
proc ButSaveNewGuiEco {} {
  global gMessage
  ButCancGuiEco 
  set gMessage "SaveNew"
}
# ***************************************************************************
# ButSaveGuiEco
# ***************************************************************************
proc ButSaveGuiEco {} {
  global gMessage
  ButCancGuiEco 
  set gMessage "Save"
}

ApprovalGui



