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
## RetriveIdTraceData DF100148093 MKTItem4Barcode
## RetriveIdTraceData 21181408    PCBTraceabilityIDData
proc RetriveIdTraceData {args} {
  package require http
  package require tls
  package require base64
  ::http::register https 8445 ::tls::socket
  global gaSet
  set gaSet(fail) ""
  puts "RetriveIdTraceData $args"
  set barc [format %.11s [lindex $args 0]]
  
  set command [lindex $args 1]
  switch -exact -- $command {
    CSLByBarcode          {set barcode $barc  ; set traceabilityID null}
    PCBTraceabilityIDData {set barcode null   ; set traceabilityID $barc}
    MKTItem4Barcode       {set barcode $barc  ; set traceabilityID null}
    OperationItem4Barcode {set barcode $barc  ; set traceabilityID null}
    default {set gaSet(fail) "Wrong command: \'$command\'"; return -1}
  }
  set url "https://ws-proxy01.rad.com:8445/ATE_WS/ws/rest/"
  set param [set command]\?barcode=[set barcode]\&traceabilityID=[set traceabilityID]
  append url $param
  puts "url:<$url>"
  set tok [::http::geturl $url -headers [list Authorization "Basic [base64::encode webservices:radexternal]"]]
  update
  set st [::http::status $tok]
  set nc [::http::ncode $tok]
  if {$st=="ok" && $nc=="200"} {
    #puts "Get $command from $barc done successfully"
  } else {
    set gaSet(fail) "http::status: <$st> http::ncode: <$nc>"; return -1
  }
  upvar #0 $tok state
  #parray state
  puts "$state(body)"
  set body $state(body)
  set jbody $state(body)
  ::http::cleanup $tok
  
  set re {[{}\[\]\,\t\:\"]}
  set tt [regsub -all $re $body " "]
  set ret [regsub -all {\s+}  $tt " "]
  set rett [lindex $ret end]
  puts ""
  set asadict [::json::json2dict $jbody]
  foreach {name wotsit} $asadict {
    set ::wit $wotsit
    puts "name:<$name> wotsit:<$wotsit>"
    foreach {par val} [lindex $wotsit 0] {
      puts "name:<$name> par:<$par> val:<$val>"
    }
  }
  # puts ""
  # set asadict2 [::json::many-json2dict $jbody]
  # foreach {name wotsit} $asadict2 {
    # puts "name:<$name> val:<$wotsit>"
  # }
  return $rett
}

# ***************************************************************************
# EcoData2DB
# ***************************************************************************
proc EcoData2DB {ecoFile} {
  puts "\nEcoData2DB $ecoFile"
  set ecoTail [file tail $ecoFile]
  set ecoFileName [lindex [split $ecoTail .] 0]
  
  sqlite3 dataBase $::db_file
  dataBase timeout 5000
  #catch {dataBase eval {SELECT count(*) from ReleasedApproved WHERE ECO = $ecoFileName}} count
  #puts "count:<$count>"
  catch {dataBase eval {SELECT Unit from ReleasedApproved WHERE ECO = $ecoFileName}} units
  set unitsLen [llength $units]
  puts "units:<$units> unitsLen:<$unitsLen>"
  
  
  set res res0
  if {$unitsLen>0} {
    catch {dataBase eval {SELECT ECO from ReleasedApproved WHERE ApprInAdv = \'yes\'}} res
    if {$res==""} {
      set res "nonAiA"
    } else {
      set res "AiA"
    }
    puts "res1:<$res>"    
  }
  
  if {$unitsLen==0 || $res=="nonAiA"} {
    puts "EcoData2DB unitsLen:<$unitsLen> res:<$res> units:<[set ::a${ecoFileName}(AI)]>"
    foreach unit [set ::a${ecoFileName}(AI)] {
      set number [set ::a${ecoFileName}(number)]
      set relDate [set ::a${ecoFileName}(releise_date)]
      catch {dataBase eval {INSERT INTO ReleasedNotApproved VALUES($number,$unit,$relDate)}} res
    }
    
    if {$res==""} {
      set res emailAndDelete
      puts "res2:<$res>"
    }
  } else {
    set res justDelete
  }
  dataBase close
  
  return $res  
}