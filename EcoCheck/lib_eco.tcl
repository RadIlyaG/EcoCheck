console show
package require http
package require base64

# ***************************************************************************
# OnRunSave
# ***************************************************************************
proc OnRunSave {id_number} {
  foreach {ret dbr_name} [split [GetDbrNameWS $id_number] _]
  
  set eco_list [RetriveEcoList $id_number]
  
  if [llength $eco_list] {
    set ret [GuiEco $id_number $eco_list]
  }
  retur $ret
}

# ***************************************************************************
# GetDbrName
#  GetDbrName DE1005790454
# ***************************************************************************
proc GetDbrName {id_number} {
  if [file exists MarkNam_$id_number.txt] {
    file delete -force MarkNam_$id_number.txt
  }
  catch {exec java -jar c:/radapps/OI4Barcode.jar $id_number} b
  set fileName MarkNam_$id_number.txt
  after 1000
  if ![file exists MarkNam_$id_number.txt] {
    set retTxt "File $fileName is not created. Verify the Barcode"
  	return fail_$retTxt
  }
  
  set fileId [open "$fileName"]
    seek $fileId 0
    set res [read $fileId]    
  close $fileId
  
  set dbr_name "[string trim $res]"
  puts "GetDbrName dbr_name:<$dbr_name>"
  
  set initName [regsub -all / $res .]
  puts "GetDbrName initName:<$initName>"
    
  file delete -force MarkNam_$id_number.txt
  
  return ok_$dbr_name
}

# ***************************************************************************
# GetDbrNameWS
# ***************************************************************************
proc GetDbrNameWS {id_number} {
  set id_number [format %.11s $id_number]
  set url "http://ws-proxy01.rad.com:10211/ATE_WS/ws/rest/"
  set param OperationItem4Barcode\?barcode=[set id_number]\&traceabilityID=null
  append url $param
  puts "GetDbrNameWS $id_number url:<$url>"
  if [catch {set tok [::http::geturl $url -headers [list Authorization "Basic [base64::encode webservices:radexternal]"]]} res] {
    return $res
  } 
  update
  set st [::http::status $tok]
  set nc [::http::ncode $tok]
  if {$st=="ok" && $nc=="200"} {
    #puts "Get $command from $barc done successfully"
  } else {
    set res "http::status: <$st> http::ncode: <$nc>"
    set ret -1
  }
  upvar #0 $tok state
  #parray state
  #puts "body:<$state(body)>"
  set body $state(body)
  ::http::cleanup $tok
  
  set re {[{}\[\]\,\t\:\"]}
  set tt [regsub -all $re $body " "]
  set ret [regsub -all {\s+}  $tt " "]
  
  return ok_[lindex $ret end]
}

proc RetriveEcoList {id_number} {
  set dbt_name
  return [list C1234 C527 C7374 C7373783 Csyx]
}

proc GuiEco {id_number eco_list} {
  set dbr_name
}

