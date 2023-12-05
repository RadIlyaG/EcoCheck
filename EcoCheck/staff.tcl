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
