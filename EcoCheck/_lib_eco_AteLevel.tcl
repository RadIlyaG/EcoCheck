console show
package require http
package require base64
package require BWidget

# ***************************************************************************
# OnRunSave
# 
# OnRunSave init DE1005790454 1
# OnRunSave run  DE1005790454 1
# ***************************************************************************
proc OnRunSave {mode id_number radNet} {
  global gMessage
  puts "\nOnRunSave $mode $id_number $radNet"
  
  set gMessage ""
  
  ## don't operate in outside RAD net
  if {$radNet==0} {return 0}
  
  puts "\nOnRunSave $mode $id_number"
  set ret [GetDbrNameWS "dbrName" $id_number]
  if {$ret!=0} {return $ret}
  set dbr_name $gMessage
  
  set ret [RetriveEcoList $dbr_name]
  if {$ret!=0} {return $ret}
  set eco_list $gMessage
  
  if [llength $eco_list] {
    set ret [GuiEco $mode $id_number $dbr_name $eco_list]
  }
  
  puts "Ret of OnRunSave: <$ret>"  
  return $ret
}

# ***************************************************************************
# GetDbrNameWS
#
#  GetDbrNameWS mrktName DE1005790488
#  GetDbrNameWS dbrName  DE1005790488
# ***************************************************************************
proc GetDbrNameWS {mode id_number} {
  global gMessage
  puts "\nGetDbrNameWS $mode $id_number"
  set id_number [format %.11s $id_number]
  set url "http://ws-proxy01.rad.com:10211/ATE_WS/ws/rest/"
  if {$mode=="dbrName"} {
    set item "OperationItem4Barcode"
  } elseif {$mode=="mrktName"} {
    set item "MKTItem4Barcode"
  }  
  set param [set item]\?barcode=[set id_number]\&traceabilityID=null
  append url $param
  #puts "GetDbrNameWS $id_number url:<$url>"
  
  set ret 0
  if [catch {set tok [::http::geturl $url -headers [list Authorization "Basic [base64::encode webservices:radexternal]"]]} res] {
    set gMessage $res
    set ret -1
  } 
  if {$ret==0} {
    update
    set st [::http::status $tok]
    set nc [::http::ncode $tok]
    if {$st=="ok" && $nc=="200"} {
      #puts "Get $command from $barc done successfully"
    } else {
      set gMessage "http::status: <$st> http::ncode: <$nc>"
      set ret -1
    }
    if {$ret==0} {
      upvar #0 $tok state
      #parray state
      #puts "body:<$state(body)>"
      set body $state(body)
      #::http::cleanup $tok
      
      set re {[{}\[\]\,\t\:\"]}
      set tt [regsub -all $re $body " "]
      set ttt [regsub -all {\s+}  $tt " "]
      set gMessage [lindex $ttt end]
      if {$gMessage=="null"} {
        set ret -1
      }
    }
  }
  puts "GetDbrNameWS gMessage:<$gMessage>"
  return $ret
}

# ***************************************************************************
# RetriveEcoList
# ***************************************************************************
proc RetriveEcoList {dbr_name} {
  global gMessage
  puts "\nRetriveEcoList $dbr_name"
  set ret 0
  set gMessage [list C1234 C527 C7374 C7373783 Csyx BC1234 C1234 C527 C7374 C7373783 Csyx BC1234 C1234 C527 C7374 C7373783 Csyx BC1234 C1234 C527 C7374 C7373783 Csyx BC1234]
  set gMessage [list C1234 C527 C7374 C7373783 Csyx BC1234]
  #set gMessage [list C1234]
  #set gMessage [list]
  return $ret
}

# ***************************************************************************
# GuiEco
# ***************************************************************************
proc GuiEco {mode id_number dbr_name {eco_list ""}} {
  global gMessage gaGui
  
  set ret 0
  puts "\nGuiEco $mode $id_number $dbr_name [list $eco_list]"
  
  set base .topGuiEco
  if [winfo exists $base] {
    wm deiconify $base
    wm deiconify .
    wm deiconify $base
    return {}
  }
  
  set mainX [winfo x .]
  set mainY [winfo y .]
  toplevel $base -class Toplevel
  wm focusmodel $base passive
  wm geometry $base +[expr {20+$mainX}]+[expr {20+$mainY}]
  wm resizable $base 1 1 
  wm title $base "ECO Verification for $dbr_name"
  
  if {$mode=="init"} {
    pack [TitleFrame $base.frChangeReason -text "Change Reason" -bd 2 -relief groove] -padx 2 -pady 2 -fill both
      set fr [$base.frChangeReason getframe]
      set labEcoNumber [Label $fr.labEcoNumber -text "ECO number"]
      set gaGui(entEcoNumber) [Entry $fr.entEcoNumber -justify center -width 10 -state normal -editable 1 ]
      
      set labNpiNumber [Label $fr.labNpiNumber -text "NPI number"]
      set gaGui(entNpiNumber) [Entry $fr.entNpiNumber -justify center -width 10 -state normal -editable 1 ]
      
      set labFtiNumber [Label $fr.labFtiNumber -text "FTI number"]
      set gaGui(entFtiNumber) [Entry $fr.entFtiNumber -justify center -width 10 -state normal -editable 1 ]
      
      grid $labEcoNumber $gaGui(entEcoNumber) -padx 2
      grid $labNpiNumber $gaGui(entNpiNumber) -padx 2
      grid $labFtiNumber $gaGui(entFtiNumber) -padx 2
  }  
  
  pack [TitleFrame $base.frChangeApproval -text "Change Approval" -bd 2 -relief groove] -padx 2 -pady 2 -fill both
    set fr [$base.frChangeApproval getframe]
    
    if [llength $eco_list] {
      if {[llength $eco_list]==1} {
        set txt "ECO $eco_list was released"
        append long_list $eco_list
        set lines 1
      } else {
        set txt "Followin ECOs were released:"
        set lines 0
        foreach {a b c d} $eco_list {
          incr lines
          append long_list "$a $b $c $d \n"
        }
      }
      set height [expr round( [expr {1.3*$lines}])]
      puts "lines:<$lines> height:<$height>" 
      set labEco [Label $fr.labEco  -text $txt -relief groove -bd 0 -font {{TkDefaultFont} 14} ] ; # -width 20 -height 24
      set labEco2 [Label $fr.labEco2 -text $long_list  -relief groove -bd 0 -font {{TkDefaultFont} 11}  -height $height] ; # -width 20 -height 24
      
      grid $labEco $labEco2 -padx 2 -sticky nw
      grid configure $labEco2 -sticky w
      
    }
    
    set gaGui(chEco) [checkbutton $fr.chEco -text "ECO"]
    set gaGui(chFti) [checkbutton $fr.chFti -text "FTI"]
    set gaGui(chNpi) [checkbutton $fr.chNpi -text "Npi"]
    
    set lab [Label $fr.lab -text "Please approve the following items are checked, verified and applied :"]
    grid $lab -columnspan 2 -padx 2 -pady 3 -sticky ew
    
    if [llength $eco_list] {
      grid $gaGui(chEco) -padx 2 -sticky w
    }
    grid $gaGui(chFti) -padx 2 -sticky w
    grid $gaGui(chNpi) -padx 2 -sticky w
  
  pack [TitleFrame $base.frApprover -text "Approver" -bd 2 -relief groove] -padx 2 -pady 2 -fill both
    set fr [$base.frApprover getframe]
    set lab [Label $fr.lab -text "Appover's Empl. Number"]
    set gaGui(entAppEmplNumber) [Entry $fr.entAppEmplNumber -justify center -width 10 -state normal -editable 1 ]
    grid $lab $gaGui(entAppEmplNumber) -padx 2 -pady 3 -sticky ew
  
  pack [frame $base.frBut ] -pady 4 -anchor e
    pack [Button $base.frBut.butCanc -text Cancel -command [list ButCancGuiEco $base] -width 7] -side right -padx 6
    pack [Button $base.frBut.butSaveNew -text "Save & New" -command [list ButSaveNewGuiEco $base] -width 11]  -side right -padx 6
    pack [Button $base.frBut.butSave -text "Save & Close" -command [list ButSaveGuiEco $base] -width 13]  -side right -padx 6
  
  focus -force $base
  grab $base
  
  return $gMessage
}
# ***************************************************************************
# ButCancGuiEco
# ***************************************************************************
proc ButCancGuiEco {base} {
  global gMessage
  grab release $base
  focus .
  destroy $base
  set gMessage "Cancel"
}
# ***************************************************************************
# ButSaveNewGuiEco
# ***************************************************************************
proc ButSaveNewGuiEco {base} {
  global gMessage
  ButCancGuiEco $base
  set gMessage "SaveNew"
}
# ***************************************************************************
# ButSaveGuiEco
# ***************************************************************************
proc ButSaveGuiEco {base} {
  global gMessage
  ButCancGuiEco $base
  set gMessage "Save"
}



