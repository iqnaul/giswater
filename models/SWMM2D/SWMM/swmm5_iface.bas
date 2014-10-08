Attribute VB_Name = "Module2"
' SWMM5_IFACE.BAS
'
' Example code for interfacing SWMM 5
' with Visual Basic Applications
'
' Remember to add SWMM5.BAS to the application

Private Type STARTUPINFO
  cb As Long
  lpReserved As String
  lpDesktop As String
  lpTitle As String
  dwX As Long
  dwY As Long
  dwXSize As Long
  dwYSize As Long
  dwXCountChars As Long
  dwYCountChars As Long
  dwFillAttribute As Long
  dwFlags As Long
  wShowWindow As Integer
  cbReserved2 As Integer
  lpReserved2 As Long
  hStdInput As Long
  hStdOutput As Long
  hStdError As Long
End Type

Private Type PROCESS_INFORMATION
  hProcess As Long
  hThread As Long
  dwProcessID As Long
  dwThreadID As Long
End Type

Private Declare Function WaitForSingleObject Lib "kernel32" (ByVal _
  hHandle As Long, ByVal dwMilliseconds As Long) As Long

Private Declare Function CreateProcessA Lib "kernel32" (ByVal _
  lpApplicationName As String, ByVal lpCommandLine As String, ByVal _
  lpProcessAttributes As Long, ByVal lpThreadAttributes As Long, _
  ByVal bInheritHandles As Long, ByVal dwCreationFlags As Long, _
  ByVal lpEnvironment As Long, ByVal lpCurrentDirectory As String, _
  lpStartupInfo As STARTUPINFO, lpProcessInformation As _
  PROCESS_INFORMATION) As Long

Private Declare Function CloseHandle Lib "kernel32" _
  (ByVal hObject As Long) As Long

Private Declare Function GetExitCodeProcess Lib "kernel32" _
  (ByVal hProcess As Long, lpExitCode As Long) As Long

Private Const SUBCATCH = 0
Private Const NODE = 1
Private Const LINK = 2
Private Const SYS = 3
Private Const INFINITE = -1&
Private Const SW_SHOWNORMAL = 1&
Private Const RECORDSIZE = 4           ' number of bytes per file record

Private SubcatchVars As Long           ' number of subcatch reporting variable
Private NodeVars As Long               ' number of node reporting variables
Private LinkVars As Long               ' number of link reporting variables
Private SysVars As Long                ' number of system reporting variables
Private Fout As Integer                ' file handle
Private StartPos As Long               ' file position where results start
Private BytesPerPeriod As Long         ' number of bytes used for storing
                                       ' results in file each reporting period

Public SWMM_Nperiods As Long           ' number of reporting periods
Public SWMM_FlowUnits As Long          ' flow units code
Public SWMM_Nsubcatch As Long          ' number of subcatchments
Public SWMM_Nnodes As Long             ' number of drainage system nodes
Public SWMM_Nlinks As Long             ' number of drainage system links
Public SWMM_Npolluts As Long           ' number of pollutants tracked
Public SWMM_StartDate As Double        ' start date of simulation
Public SWMM_ReportStep As Long         ' reporting time step (seconds)


Public Function RunSwmmExe(cmdLine As String) As Long
'------------------------------------------------------------------------------
'  Input:   cmdLine = command line for running the console version of SWMM 5
'  Output:  returns the exit code generated by running SWMM5.EXE
'  Purpose: runs the command line version of SWMM 5.
'------------------------------------------------------------------------------
Dim pi As PROCESS_INFORMATION
Dim si As STARTUPINFO
Dim exitCode As Long

' --- Initialize data structures
si.cb = Len(si)
si.wShowWindow = SW_SHOWNORMAL

' --- launch swmm5.exe
exitCode = CreateProcessA(vbNullString, cmdLine, 0&, 0&, 0&, _
                0&, 0&, vbNullString, si, pi)

' --- wait for program to end
exitCode = WaitForSingleObject(pi.hProcess, INFINITE)

' --- retrieve the error code produced by the program
Call GetExitCodeProcess(proc.hProcess, exitCode)

' --- release handles
Call CloseHandle(pi.hThread)
Call CloseHandle(pi.hProcess)
RunSwmmExe = exitCode
End Function


Public Function RunSwmmDll(inpFile As String, rptFile As String, _
       OutFile As String) As Long
'------------------------------------------------------------------------------
'  Input:   inpFile = name of SWMM 5 input file
'           rptFile = name of status report file
'           outFile = name of binary output file
'  Output:  returns a SWMM 5 error code or 0 if there are no errors
'  Purpose: runs the dynamic link library version of SWMM 5.
'------------------------------------------------------------------------------
Dim err As Long
Dim elapsedTime As Double

' --- open a SWMM project
err = swmm_open(inpFile, rptFile, OutFile)
If err = 0 Then

  ' --- initialize all processing systems
  err = swmm_start(1)
  If err = 0 Then

    ' --- step through the simulation
    Do
      ' --- allow Windows to process any pending events
      DoEvents

      ' --- extend the simulation by one routing time step
      err = swmm_step(elapsedTime)

      '//////////////////////////////////////////
      ' call a progress reporting function here,
      ' using elapsedTime as an argument
      '//////////////////////////////////////////
    
    Loop While elapsedTime > 0# And err = 0
  End If

  ' --- close all processing systems
  swmm_end
End If

' --- close the project
swmm_close

' --- return the error code
RunSwmmDll = err
End Function


Function OpenSwmmOutFile(OutFile As String) As Long
'------------------------------------------------------------------------------
'  Input:   outFile = name of binary output file
'  Output:  returns 0 if successful, 1 if binary file invalid because
'           SWMM 5 ran with errors, or 2 if the file cannot be opened
'  Purpose: opens the binary output file created by a SWMM 5 run and
'           retrieves the following simulation data that can be
'           accessed by the application:
'           SWMM_Nperiods = number of reporting periods
'           SWMM_FlowUnits = flow units code
'           SWMM_Nsubcatch = number of subcatchments
'           SWMM_Nnodes = number of drainage system nodes
'           SWMM_Nlinks = number of drainage system links
'           SWMM_Npolluts = number of pollutants tracked
'           SWMM_StartDate = start date of simulation
'           SWMM_ReportStep = reporting time step (seconds)
'------------------------------------------------------------------------------
Dim magic1 As Long
Dim magic2 As Long
Dim errCode As Long
Dim version As Long
Dim offset As Long
Dim offset0 As Long
Dim err As Long

' --- open the output file
On Error GoTo FINISH
err = 2
Fout = FreeFile
Open OutFile For Binary Access Read As #Fout

' --- check that file contains at least 14 records
If LOF(1) < 14 * RECORDSIZE Then
  OpenOutFile = 1
  Close Fout
  Exit Function
End If

' --- read parameters from end of file
Seek #Fout, LOF(Fout) - 5 * RECORDSIZE + 1
Get #Fout, , offset0
Get #Fout, , StartPos
Get #Fout, , SWMM_Nperiods
Get #Fout, , errCode
Get #Fout, , magic2

' --- read magic number from beginning of file
Seek #Fout, 1
Get #Fout, , magic1

' --- perform error checks
If magic1 <> magic2 Then
  err = 1
ElseIf errCode <> 0 Then
  err = 1
ElseIf SWMM_Nperiods = 0 Then
  err = 1
Else
  err = 0
End If

' --- quit if errors found
If err > 0 Then
  Close (Fout)
  OpenOutFile = err
  Exit Function
End If

' --- otherwise read additional parameters from start of file
Get #Fout, , version
Get #Fout, , SWMM_FlowUnits
Get #Fout, , SWMM_Nsubcatch
Get #Fout, , SWMM_Nnodes
Get #Fout, , SWMM_Nlinks
Get #Fout, , SWMM_Npolluts

' --- skip over saved subcatch/node/link input values
offset = (SWMM_Nsubcatch + 2) * RECORDSIZE
offset = offset + (3 * SWMM_Nnodes + 4) * RECORDSIZE
offset = offset + (5 * SWMM_Nlinks + 6) * RECORDSIZE
offset = offset0 + offset + 1
Seek #Fout, offset

' --- read number & codes of computed variables
Get #Fout, , SubcatchVars
Seek #Fout, Seek(Fout) + (SubcatchVars * RECORDSIZE)
Get #Fout, , NodeVars
Seek #Fout, Seek(Fout) + (NodeVars * RECORDSIZE)
Get #Fout, , LinkVars
Seek #Fout, Seek(Fout) + (LinkVars * RECORDSIZE)
Get #Fout, , SysVars

' --- read data just before start of output results
Seek #Fout, StartPos - 3 * RECORDSIZE + 1
Get #Fout, , SWMM_StartDate
Get #Fout, , SWMM_ReportStep

' --- compute number of bytes stored per reporting period
BytesPerPeriod = RECORDSIZE * 2
BytesPerPeriod = BytesPerPeriod + RECORDSIZE * SWMM_Nsubcatch * SubcatchVars
BytesPerPeriod = BytesPerPeriod + RECORDSIZE * SWMM_Nnodes * NodeVars
BytesPerPeriod = BytesPerPeriod + RECORDSIZE * SWMM_Nlinks * LinkVars
BytesPerPeriod = BytesPerPeriod + RECORDSIZE * SysVars

' --- return with file left open
OpenSwmmOutFile = err
Exit Function

' --- error handler
FINISH:
OpenSwmmOutFile = err
Close (Fout)
End Function


Function GetSwmmResult(ByVal iType As Long, ByVal iIndex As Long, _
         ByVal vIndex As Long, ByVal period As Long, Value As Single) As Integer
'------------------------------------------------------------------------------
'  Input:   iType = type of object whose value is being sought
'                   (0 = subcatchment, 1 = node, 2 = link, 3 = system
'           iIndex = index of item being sought (starting from 0)
'           vIndex = index of variable being sought (see Interfacing Guide)
'           period = reporting period index (starting from 1)
'  Output:  value = value of variable being sought;
'           function returns 1 if successful, 0 if not
'  Purpose: finds the result of a specific variable for a given object
'           at a specified time period.
'------------------------------------------------------------------------------
Dim offset As Long
Dim offset1 As Long
Dim offset2 As Long
Dim X As Single

'// --- compute offset into output file
Value = 0#
GetSwmmResult = 0
offset1 = StartPos + (period - 1) * BytesPerPeriod + 2 * RECORDSIZE + 1
offset2 = 0
If iType = SUBCATCH Then
  offset2 = iIndex * SubcatchVars + vIndex
ElseIf iType = NODE Then
  offset2 = SWMM_Nsubcatch * SubcatchVars + iIndex * NodeVars + vIndex
ElseIf iType = LINK Then
  offset2 = SWMM_Nsubcatch * SubctchVars + SWMM_Nnodes * NodeVars + iIndex * LinkVars + vIndex
ElseIf iType = SYS Then
  offset2 = SWMM_Nsubcatch * SubcatchVars + SWMM_Nnodes * NodeVars + SWMM_Nlinks * LinkVars + vIndex
Else: Exit Function
End If

'// --- re-position the file and read result
offset = offset1 + RECORDSIZE * offset2
Seek #Fout, offset
Get #Fout, , X
Value = X
GetSwmmResult = 1
End Function


Public Sub CloseSwmmOutFile()
'------------------------------------------------------------------------------
'  Input:   none
'  Output:  none
'  Purpose: closes the binary output file.
'------------------------------------------------------------------------------
Close (Fout)
End Sub
