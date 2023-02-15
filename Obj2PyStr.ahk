; Modified from obj2str.ahk by errorseven.
; burque505 Feb 14 2023
; (No, I'm not thrilled about the name of my script :))

; The motivating factor for this mod was a desire to export AHK v1 objects to stdout via 'FileAppend, % obj2str(YourObjectHere), *'
; and process the result in Python, using the library 'ahk'

; https://github.com/spyoungtech/ahk
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=63184&p=270111&hilit=spyoungtech#p270111

; A requirement is the ability to process multiline strings in both AHK and Python,
; which meant jumping through some hoops with continuation sections and StrReplace().
; I also need to be able to process underscores in key names in dictionaries.

; AHK Script 'your_script_here5.ahk'
/*
#Include obj2pystr.ahk

hughes = 
(
John James Hughes
as Trusteee
of the J.J. Hughes Revocable Living Trust
)

MyStuff := [1, 2, 3, 5, hughes]
;MsgBox % Obj2PyStr(MyDict)
FileAppend, % Obj2PyStr(MyStuff), *
*/

; python to read the output of that script
/*
from ahk import AHK
from ast import literal_eval

ahk = AHK()

with open(r"your_script_here5.ahk", 'r') as f:
    my_script =  f.read()

result = ahk.run_script(my_script)
print(result)  
NewStuff = literal_eval(result)
print(type(NewStuff))
print(NewStuff[4])
*/

; Result:
/*
[1, 2, 3, 5, '''John James Hughes
as Trusteee
of the J.J. Hughes Revocable Living Trust''']
<class 'list'>
John James Hughes
as Trusteee
of the J.J. Hughes Revocable Living Trust
*/

; Now for a 'Dictionary' (associative array in AHK v1)
; AHK Script 'your_script_here4.ahk'
/*
#Include obj2pystr.ahk

hughes = 
(
John James Hughes
as Trusteee
of the J.J. Hughes Revocable Living Trust
)

MyDict := {borrowers:[{1_FullName:"James Roberts", 2_Street:"346 Cage St", 3_City:"Tarzana", 4_State:"CA", 5_Zip:90111}]
, lenders:[{1_FullName:hughes, 2_Street:"123 Anywhere", 3_City:"Albacore", 4_State:"NT", 5_Zip:80111}]}

;MsgBox % Obj2PyStr(MyDict)
FileAppend, % Obj2PyStr(MyDict), *

*/

; Python script to process this:
/*
from ahk import AHK
#import json
from ast import literal_eval

ahk = AHK()

with open(r"your_script_here4.ahk", 'r') as f:
    my_script =  f.read()

result = ahk.run_script(my_script)
print(result)  
NewStuff = literal_eval(result)
print(type(NewStuff))
print(NewStuff["lenders"][0]["1_FullName"])
*/

; Result:
/*
{"borrowers":[{"1_FullName":'''James Roberts''', "2_Street":'''346 Cage St''', "3_City":'''Tarzana''', "4_State":'''CA''', "5_Zip":90111}], "lenders":[{"1_FullName":'''John James Hughes
as Trusteee
of the J.J. Hughes Revocable Living Trust''', "2_Street":'''123 Anywhere''', "3_City":'''Albacore''', "4_State":'''NT''', "5_Zip":80111}]}
<class 'dict'>
John James Hughes
as Trusteee
of the J.J. Hughes Revocable Living Trust
*/

; NOTE:
; Use ast (from ast import )
; Other AHK objects remain untested


Obj2PyStr(obj) { 
 
    Linear := True
    
    While (A_Index != obj.MaxIndex()) {
        if !(obj.hasKey(A_Index)) {
            Linear := False
            break
        }
    }

    For e, v in obj {
        if (Linear == False) {
            if (IsObject(v)) 
               r .= """" e """" ":" Obj2PyStr(v) ", "        
            else {                  
                r .= """" e """" ":"  
                if v is number 
                    r .= v ", "
                else {
                    v = 
                    (join`n
                        %v%
                    )
                    v := StrReplace(v, "\n", "``n")
                    r .= "'''" . v . "'''" . ", "
                }
            }            
        } else {
            if (IsObject(v)) 
                r .= Obj2PyStr(v) ", "
            else {          
                if v is number 
                    r .= v ", "
                else {
                    v = 
                    (join`n
                        %v%
                    )
                    v := StrReplace(v, "\n", "``n")
                    r .= "'''" . v . "'''" . ", "
                }
            }
        }
    }
    return Linear ? "[" trim(r, ", ") "]" 
                 : "{" trim(r, ", ") "}"
}
