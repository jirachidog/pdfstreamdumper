VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Begin VB.Form Form2 
   Caption         =   "Bulk Hash Lookup"
   ClientHeight    =   7770
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   9210
   LinkTopic       =   "Form2"
   ScaleHeight     =   7770
   ScaleWidth      =   9210
   StartUpPosition =   2  'CenterScreen
   Begin VB.Timer tmrDelay 
      Enabled         =   0   'False
      Interval        =   4500
      Left            =   3360
      Top             =   630
   End
   Begin VB.CommandButton cmdAbort 
      Caption         =   "Abort"
      Height          =   405
      Left            =   7650
      TabIndex        =   7
      Top             =   60
      Width           =   1455
   End
   Begin VB.CommandButton cmdClear 
      Caption         =   "Clear List"
      Height          =   405
      Left            =   3570
      TabIndex        =   6
      Top             =   60
      Width           =   1905
   End
   Begin MSComctlLib.ProgressBar pb 
      Height          =   285
      Left            =   60
      TabIndex        =   5
      Top             =   1740
      Width           =   9105
      _ExtentX        =   16060
      _ExtentY        =   503
      _Version        =   393216
      Appearance      =   1
   End
   Begin VB.CommandButton cmdQuery 
      Caption         =   "Begin Query"
      Height          =   405
      Left            =   5550
      TabIndex        =   4
      Top             =   60
      Width           =   2055
   End
   Begin VB.TextBox Text2 
      BeginProperty Font 
         Name            =   "Courier"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   3165
      Left            =   30
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   3
      Top             =   4530
      Width           =   9165
   End
   Begin VB.CommandButton cmdLoadHashs 
      Caption         =   "Load Hashs one per line from clipboard"
      Height          =   405
      Left            =   60
      TabIndex        =   2
      Top             =   60
      Width           =   3435
   End
   Begin MSComctlLib.ListView lv 
      Height          =   2445
      Left            =   30
      TabIndex        =   1
      Top             =   2040
      Width           =   9135
      _ExtentX        =   16113
      _ExtentY        =   4313
      View            =   3
      LabelEdit       =   1
      MultiSelect     =   -1  'True
      LabelWrap       =   0   'False
      HideSelection   =   0   'False
      FullRowSelect   =   -1  'True
      GridLines       =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   2
      BeginProperty ColumnHeader(1) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         Text            =   "hash"
         Object.Width           =   10583
      EndProperty
      BeginProperty ColumnHeader(2) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   1
         Text            =   "detections"
         Object.Width           =   2540
      EndProperty
   End
   Begin VB.ListBox List1 
      BeginProperty Font 
         Name            =   "Courier"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   1230
      Left            =   30
      TabIndex        =   0
      Top             =   510
      Width           =   9135
   End
   Begin VB.Menu mnuPopup 
      Caption         =   "mnuPopup"
      Visible         =   0   'False
      Begin VB.Menu mnuCopyTable 
         Caption         =   "Copy Table"
      End
      Begin VB.Menu mnuCopyResult 
         Caption         =   "Copy Result"
      End
      Begin VB.Menu mnuCopyAll 
         Caption         =   "Copy All Results"
      End
      Begin VB.Menu mnuRemoveSelected 
         Caption         =   "Remove Selected"
      End
   End
End
Attribute VB_Name = "Form2"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Public frmMain As Object
Dim vt As New CVirusTotal
Dim md5 As New MD5Hash
Private Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
Dim selli As ListItem
Dim abort As Boolean

Private Sub cmdAbort_Click()
    abort = True
End Sub

Private Sub cmdClear_Click()
    List1.Clear
    lv.ListItems.Clear
    Text2 = Empty
    Set selli = Nothing
End Sub

Private Sub cmdQuery_Click()
    
    Dim report As String
    Dim detections As Long
    Dim li As ListItem
    
    On Error Resume Next
    
    If lv.ListItems.Count = 0 Then
        MsgBox "Load hashs first!"
        Exit Sub
    End If
    
    abort = False
    
    pb.Max = lv.ListItems.Count
    
    For Each li In lv.ListItems
    
        If abort Then Exit For
        
        If Len(Trim(li.Text)) = 0 Then GoTo nextone
        
        If vt.GetVTReport(li.Text, report, detections) Then
            li.SubItems(1) = detections
            If Len(report) > 0 Then
                li.Tag = report
            End If
            tmp = Split(report, vbCrLf)
            For Each x In tmp
                List1.AddItem x
            Next
        Else
            li.SubItems(1) = "Failure"
        End If
        
        li.EnsureVisible
        DoEvents
        Me.Refresh
        pb.Value = pb.Value + 1
        
        If pb.Value = lv.ListItems.Count Then GoTo nextone
        
        If Not vt.WasCached Then
            tmrDelay.Enabled = True
            While tmrDelay.Enabled
                DoEvents
                Sleep 200
            Wend
        End If
        
        
nextone:
    Next
    
    pb.Value = 0
    MsgBox "Complete Click on an item to view report.", vbInformation
 
 
End Sub



Private Sub Command2_Click()
'    Dim m_json As String
'    Dim b As String
'    Dim c As Long
'    Dim d As Dictionary
'
'    If AddComment(txtHash, Text2, m_json, b, c) Then
'        Set d = JSON.parse(m_json)
'        If d Is Nothing Then
'            List1.AddItem "AddComment JSON parsing error"
'            Exit Sub
'        End If
'
'        If JSON.GetParserErrors <> "" Then
'            List1.AddItem "AddComment Json Parse Error: " & JSON.GetParserErrors
'            Exit Sub
'        End If
'
'        If d.Item("response") <> 1 Then
'            MsgBox d.Item("verbose_msg")
'            Exit Sub
'        End If
'
'        MsgBox "Comment was added successfully", vbInformation
'
'    Else
'        MsgBox "Add Comment Failed Status code: " & c & " " & b
'    End If
        
   
    
End Sub

Private Sub cmdLoadHashs_Click()
    x = Clipboard.GetText
    tmp = Split(x, vbCrLf)
    For Each x In tmp
        If Len(Trim(x)) > 0 Then lv.ListItems.Add , , Trim(x)
    Next
End Sub

Private Sub Form_Load()
    
    Set vt.List1 = List1
 
End Sub


Private Sub lv_ItemClick(ByVal Item As MSComctlLib.ListItem)
    Text2 = Item.Tag
    Set selli = Item
End Sub

Private Sub lv_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)
    If Button = 2 Then PopupMenu mnuPopup
End Sub

Private Sub mnuCopyAll_Click()
    Dim li As ListItem
    Dim r
    
    For Each li In lv.ListItems
        r = r & li.Text & "  Detections: " & li.SubItems(1) & vbCrLf
    Next
    
    r = r & vbCrLf & vbCrLf
    
    For Each li In lv.ListItems
        r = r & li.Text & vbCrLf & li.Tag & vbCrLf & String(50, "-") & vbCrLf
    Next
    
    Clipboard.Clear
    Clipboard.SetText r
    MsgBox Len(r) & " bytes copied to clipboard"
    
End Sub

Private Sub mnuCopyResult_Click()

    If selli Is Nothing Then
        MsgBox "Nothing selected"
        Exit Sub
    End If
    
    Dim r As String
    r = selli.Text & "  Detections: " & selli.SubItems(1) & vbCrLf & String(50, "-") & vbCrLf & selli.Tag
    Clipboard.Clear
    Clipboard.SetText r
    MsgBox Len(r) & " bytes copied to clipboard"
    
End Sub

Private Sub mnuCopyTable_Click()

    Dim li As ListItem
    Dim r
    
    For Each li In lv.ListItems
        r = r & li.Text & "  Detections: " & li.SubItems(1) & vbCrLf
    Next
    
    Clipboard.Clear
    Clipboard.SetText r
    MsgBox Len(r) & " bytes copied to clipboard"
    
End Sub

Private Sub mnuRemoveSelected_Click()
    On Error Resume Next
    
    For i = lv.ListItems.Count To 1 Step -1
        If lv.ListItems(i).Selected Then lv.ListItems.Remove i
    Next
    
End Sub

Private Sub tmrDelay_Timer()
    tmrDelay.Enabled = False
End Sub



