wm iconify . ; update
#console show
package require registry
set jav [registry -64bit get "HKEY_LOCAL_MACHINE\\SOFTWARE\\javasoft\\Java Runtime Environment" CurrentVersion]
set gaSet(javaLocation) [file normalize [registry -64bit get "HKEY_LOCAL_MACHINE\\SOFTWARE\\javasoft\\Java Runtime Environment\\$jav" JavaHome]/bin]

package require http
package require base64
package require BWidget
package require sqlite3

set ::RadAppsPath c:/RadApps
set gaSet(radNet) 0
foreach {jj ip} [regexp -all -inline {v4 Address[\.\s\:]+([\d\.]+)} [exec ipconfig]] {
  if {[string match {*192.115.243.*} $ip] || [string match {*172.18.9*} $ip] || [string match {*172.17.9*} $ip]} {
    set gaSet(radNet) 1
  }  
}
if 1 {
  package require RLAutoSync
  proc TesterAutoSync {} {
    global gaSet gMessage

    set s1 [file normalize //prod-svm1/tds/AT-Testers/JER_AT/ilya/Tools/EcoCheckProject/EcoCheck/TLpc]
    set d1 [file normalize  [pwd]]
    set sdL [list $s1 $d1]
    set emailL [list]
    
    set ret [RLAutoSync::AutoSync $sdL -noCheckFiles {init*.* *.db}  -jarLocation $::RadAppsPath \
        -javaLocation $gaSet(javaLocation) -emailL $emailL -putsCmd 1 -radNet $gaSet(radNet)]
    #console show
    puts "ret:<$ret>"
    set gsm $gMessage
    set rt $ret
    foreach gmess $gMessage {
      puts "$gmess"
    }
    update
    
    
    if {$ret=="-1"} {
      if [string match *Exception* $gMessage] {
        set txt "Network connection problem"
        set res [tk_messageBox -icon error -type ok -title "AutoSync Network problem"\
          -message "Network connection problem"]
      } else {
        set res [tk_messageBox -icon error -type yesno -title "AutoSync"\
          -message "The AutoSync process did not perform successfully.\n\n\
          Do you want to continue? "]
        if {$res=="no"} {
          #SQliteClose
          exit
        } else {
          set ret 0
        }
      }
    } 
    return $ret
  }
    
  set ret [TesterAutoSync]
  
  
}
set db_file \\\\prod-svm1\\tds\\Temp\\SQLiteDB\\EcoCheck.db

package require RLSound
RLSound::Open

source lib_ApprGuiMain.tcl
source Lib_DialogBox.tcl
if [catch {source init.tcl} res] {
  set gaApprGui(xy) "+100+100"
}
puts "<$res>"


Gui
wm deiconify .
wm geometry . $gaApprGui(xy)


