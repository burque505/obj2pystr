;NO WORKEE!!!     


; Modified from obj2str.ahk by errorseven.
; burque505 Feb 14 2023
; (No, I'm not thrilled about the name of my script :))

; Given the following object:
/*
MyDict := {borrowers:[{1_FullName:"John Roberts", 2_Street:"123 Anywhere St", 3_City:"Las Vegas", 4_State:"LV", 5_Zip:89112}
, {1_FullName:"Jane Roberts", 2_Street:"123 Anywhere St", 3_City:"Las Vegas", 4_State:"LV", 5_Zip:89112}]
, lenders:[{1_FullName:"Primate Trust, Inc.", 2_Street:"9988 W. Flamingo Suite 800", 3_City:"Las Vegas", 4_State:"LV", 5_Zip:89112}]}
FileAppend, % Obj2Str(MyDict), *
*/
; 'obj2pystr(MyDict)' returns:
/*
{'borrowers': [{'1_FullName': 'John Roberts', '2_Street': '123 Anywhere St', '3_City': 'Las Vegas', '4_State': 'LV', '5_Zip': 89112}
, {'1_FullName': 'Jane Roberts', '2_Street': '123 Anywhere St', '3_City': 'Las Vegas', '4_State': 'LV', '5_Zip': 89112}]
, 'lenders': [{'1_FullName': 'Zia Trust, Inc. as custodian', '2_Street': '9988 W. Flamingo Suite 800', '3_City': 'Las Vegas', '4_State': 'LV', '5_Zip': 87110}]}
*/

; The motivating factor for this mod was a desire to export AHK v1 objects to stdout via 'FileAppend, % obj2str(YourObjectHere), *'
; and process the result in Python, using the library 'ahk'
; https://github.com/spyoungtech/ahk
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=63184&p=270111&hilit=spyoungtech#p270111

; Here's a sample python script to process the result passed from ahk to python:
/*
from ahk import AHK
import json

ahk = AHK()

with open(r"your_script_name_here.ahk", 'r') as f:
    my_script =  f.read()

#print(my_script)
result = ahk.run_script(my_script)
#print(result)  # Hello Data!pahk
res = json.loads(result)
print(str(res))
*/

; NOTE:
; I've tried doing the processing only on the python side, e.g. using the json5 lib, but my results have been spotty.
; (in the example, json5 choked on the underscores)

; NOTE:
; 



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
