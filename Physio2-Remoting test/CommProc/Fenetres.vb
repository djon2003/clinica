Module Fenetres

    Public sectorsLocked As New Generic.List(Of String)

    Public Sub openContact(ByVal contactFolder As ContactFolder, ByVal noContact As Integer)
        'Droit & Accès
        If contactFolder Is Nothing Then
            'Message & Exit
            MessageBox.Show("Vous n'avez pas accès au dossier contenant ce contact." & vbCrLf & "Merci!", "Droit & Accès")
            Exit Sub
        End If

        Dim myMsgContact As msgContact = openUniqueWindow(New msgContact())
        myMsgContact.Visible = False
        myMsgContact.loading(contactFolder.noContactFolder, noContact)
        myMsgContact.MdiParent = Nothing
        myMsgContact.StartPosition = FormStartPosition.CenterScreen
        myMsgContact.ShowDialog()
    End Sub

    Public Sub openRapport()
        'Droit & Accès
        If currentDroitAcces(69) = False Then
            'Message & Exit
            MessageBox.Show("Vous n'avez pas accès à ce secteur du logiciel : Générateur de rapport." & vbCrLf & "Merci!", "Droit & Accès")
            Exit Sub
        End If

        Dim myRapportGeneration As ReportGeneration = openUniqueWindow(New ReportGeneration)
        myRapportGeneration.Show()
    End Sub

    Public Sub openFinDeMois()
        'Droit & Accès
        If currentDroitAcces(65) = False Then
            'Message & Exit
            MessageBox.Show("Vous n'avez pas accès à ce secteur du logiciel : Fin de mois." & vbCrLf & "Merci!", "Droit & Accès")
            Exit Sub
        End If

        Dim myFinMois As EndOfMonth = openUniqueWindow(New EndOfMonth)
        myFinMois.Show()
    End Sub

    Public Sub setVisibility(ByRef containerFrom As ContainerControl, Optional ByVal estVisible As Boolean = True, Optional ByVal taggedNoHideNotModified As Boolean = True)
        Dim i As Integer
        With containerFrom
            For i = 0 To .Controls.Count - 1
                If (taggedNoHideNotModified = False Or (taggedNoHideNotModified = True And InStr(.Controls(i).Tag, "NOHIDE", CompareMethod.Text) = 0)) Then .Controls(i).Visible = estVisible
            Next i
        End With
    End Sub

    Public Sub setEnability(ByRef containerFrom As ContainerControl, Optional ByVal estEnable As Boolean = True)
        Dim i As Integer
        With containerFrom
            For i = 0 To .Controls.Count - 1
                .Controls(i).Enabled = estEnable
            Next i
        End With
    End Sub

    Public Function lockedVerification(ByVal fileName As String, Optional ByVal startingWith As Boolean = False) As Boolean
        If isNewLockMethodChecked = False Then
            isNewLockMethodChecked = True
            If IO.File.Exists(appPath & bar(appPath) & "lock.new") Then isNewLockMethod = True
        End If

        If isNewLockMethod Then
            Dim lockToCheck As New Lock(fileName, String.Empty, TCPClient.getInstance().name)

            Return LocksManager.getInstance().isSectorLocked(lockToCheck, startingWith)
        End If


        If startingWith Then
            Dim files() As String = IO.Directory.GetFiles(appPath & bar(appPath) & "Data\LockSecteur", fileName & "*", IO.SearchOption.TopDirectoryOnly)
            Return files.Length <> 0
        End If

        Return IO.File.Exists(appPath & bar(appPath) & "Data\LockSecteur\" & fileName)
    End Function

    Public Sub configList(ByRef listToChange As CI.Controls.List, Optional ByVal couleurFond As Object = Nothing)
        Dim curFS As FontStyle = FontStyle.Regular
        If PreferencesManager.getGeneralPreferences()("ListGras") Then curFS += FontStyle.Bold
        If PreferencesManager.getGeneralPreferences()("ListItalique") Then curFS += FontStyle.Italic
        If PreferencesManager.getGeneralPreferences()("ListBarre") Then curFS += FontStyle.Strikeout
        If PreferencesManager.getGeneralPreferences()("ListSouligne") Then curFS += FontStyle.Underline

        If Not PreferencesManager.getGeneralPreferences()("ListFont") = "" Then
            Try
                listToChange.baseFont = New Font(PreferencesManager.getGeneralPreferences()("ListFont"), CInt(PreferencesManager.getGeneralPreferences()("ListFontSize")), curFS)
            Catch ex As ArgumentException
                'La sorte d'écriture ne supporte pas l'écriture normal.. 
                listToChange.baseFont = New Font(PreferencesManager.getGeneralPreferences()("ListFont"), CInt(PreferencesManager.getGeneralPreferences()("ListFontSize")), FontStyle.Italic)
            End Try
        End If
        If Not PreferencesManager.getGeneralPreferences()("ListBorder") Is Nothing Then listToChange.itemBorder = PreferencesManager.getGeneralPreferences()("ListBorder")
        If Not PreferencesManager.getGeneralPreferences()("ListMarge") Is Nothing Then listToChange.itemMargin = PreferencesManager.getGeneralPreferences()("ListMarge")
        If Not PreferencesManager.getGeneralPreferences()("ListMouseSpeed") Is Nothing Then listToChange.mouseSpeed = PreferencesManager.getGeneralPreferences()("ListMouseSpeed")
        If couleurFond Is Nothing Then
            If Not PreferencesManager.getGeneralPreferences()("ListColors1") Is Nothing Then listToChange.bgColor = System.Drawing.ColorTranslator.FromOle(PreferencesManager.getGeneralPreferences()("ListColors1"))
        Else
            listToChange.bgColor = couleurFond
        End If

        If Not PreferencesManager.getGeneralPreferences()("ListColors2") Is Nothing Then listToChange.baseBackColor = System.Drawing.ColorTranslator.FromOle(PreferencesManager.getGeneralPreferences()("ListColors2"))
        If Not PreferencesManager.getGeneralPreferences()("ListColors3") Is Nothing Then listToChange.borderColor = System.Drawing.ColorTranslator.FromOle(PreferencesManager.getGeneralPreferences()("ListColors3"))
        If Not PreferencesManager.getGeneralPreferences()("ListColors4") Is Nothing Then listToChange.hScrollColor = System.Drawing.ColorTranslator.FromOle(PreferencesManager.getGeneralPreferences()("ListColors4"))
        If Not PreferencesManager.getGeneralPreferences()("ListColors4") Is Nothing Then listToChange.vScrollColor = System.Drawing.ColorTranslator.FromOle(PreferencesManager.getGeneralPreferences()("ListColors4"))
        If Not PreferencesManager.getGeneralPreferences()("ListColors5") Is Nothing Then listToChange.borderSelColor = System.Drawing.ColorTranslator.FromOle(PreferencesManager.getGeneralPreferences()("ListColors5"))
        If Not PreferencesManager.getGeneralPreferences()("ListColors6") Is Nothing Then listToChange.hScrollForeColor = System.Drawing.ColorTranslator.FromOle(PreferencesManager.getGeneralPreferences()("ListColors6"))
        If Not PreferencesManager.getGeneralPreferences()("ListColors6") Is Nothing Then listToChange.vScrollForeColor = System.Drawing.ColorTranslator.FromOle(PreferencesManager.getGeneralPreferences()("ListColors6"))
        If Not PreferencesManager.getGeneralPreferences()("ListColors7") Is Nothing Then listToChange.baseForeColor = System.Drawing.ColorTranslator.FromOle(PreferencesManager.getGeneralPreferences()("ListColors7"))
        If Not PreferencesManager.getGeneralPreferences()("Do3DOpt") Is Nothing Then listToChange.do3D = PreferencesManager.getGeneralPreferences()("Do3DOpt")
        If Not PreferencesManager.getGeneralPreferences()("MouseOver3DOpt") Is Nothing Then listToChange.mouseMove3D = PreferencesManager.getGeneralPreferences()("MouseOver3DOpt")

        listToChange.clickEnabled = True
    End Sub

    Public Function lockSecteurs(ByVal fileNames() As String, ByVal trueFalse As Boolean, Optional ByVal sectors() As String = Nothing, Optional ByVal affLockMSG As Boolean = True) As Boolean
        Dim nbLocked As Integer = 0
        Dim sector As String = ""
        'Try to lock all the demanded sectors
        For nbLocked = 0 To fileNames.GetUpperBound(0)
            If sectors IsNot Nothing Then
                If sectors.GetUpperBound(0) >= nbLocked Then
                    sector = sectors(nbLocked)
                Else
                    sector = ""
                End If
            End If
            If lockSecteur(fileNames(nbLocked), trueFalse, sector, affLockMSG) = False Then Exit For
        Next nbLocked

        'On locking, if not all locked, rollback the ones locked
        If trueFalse AndAlso nbLocked <> fileNames.Length Then
            For i As Integer = 0 To nbLocked - 1
                If sectors IsNot Nothing Then
                    If sectors.GetUpperBound(0) >= nbLocked Then
                        sector = sectors(nbLocked)
                    Else
                        sector = ""
                    End If
                End If
                lockSecteur(fileNames(i), False, sector, affLockMSG)
            Next i

            Return False
        End If

        Return True
    End Function

    Private lockSectorLock As New Threading.Mutex()
    Private isNewLockMethod As Boolean = False
    Private isNewLockMethodChecked As Boolean = False


    Public Function lockSecteur(ByVal fileName As String, ByVal isLocked As Boolean, Optional ByVal secteur As String = "", Optional ByVal affLockMSG As Boolean = True) As Boolean
        If isNewLockMethodChecked = False Then
            isNewLockMethodChecked = True
            'TODO: Reactive when LocksManager TODO are done
            'If IO.File.Exists(appPath & bar(appPath) & "lock.new") Then isNewLockMethod = True
        End If

        Dim msg As String = "Impossible de modifier le secteur """ & secteur & """. Il est déjà en cours de modification par un autre utilisateur."
        If isNewLockMethod Then
            Dim lockToDo As New Lock(fileName, secteur, TCPClient.getInstance().name)

            Dim didLock As Boolean = LocksManager.getInstance().lockSector(lockToDo, isLocked)
            If isLocked AndAlso Not didLock AndAlso affLockMSG AndAlso PreferencesManager.getUserPreferences()("AffMSGModif") = True Then
                MessageBox.Show(msg, secteur, MessageBoxButtons.OK, MessageBoxIcon.Exclamation)
            End If

            Return didLock
        End If

        Dim fileCurrentUser As Integer
        Dim DateTemps, fullDir As String
        Dim fileStream As IO.FileStream

        fullDir = appPath & bar(appPath) & "Data\LockSecteur"
        IO.Directory.CreateDirectory(fullDir)

        msg = "Impossible de modifier le secteur """ & secteur & """. Il est déjà en cours de modification par un autre utilisateur."

        lockSectorLock.WaitOne()
        If isLocked = True Then
            If IO.File.Exists(fullDir & "\" & fileName) = True Then
                If affLockMSG = True Then If PreferencesManager.getUserPreferences()("AffMSGModif") = True Then MessageBox.Show(msg, secteur, MessageBoxButtons.OK, MessageBoxIcon.Exclamation)
                lockSectorLock.ReleaseMutex()
                Return False
            End If

            Try
                fileStream = IO.File.Open(fullDir & "\" & fileName, IO.FileMode.CreateNew, IO.FileAccess.Write, IO.FileShare.None)
                Dim file As New IO.StreamWriter(fileStream)
                file.WriteLine(ConnectionsManager.currentUser)
                file.WriteLine(Date.Today.ToString("yyyy-MM-dd") & Date.Now.ToString("HH:mm:ss"))
                file.Flush()

            Catch ex As Exception
                If affLockMSG = True Then If PreferencesManager.getUserPreferences()("AffMSGModif") = True Then MessageBox.Show(msg, secteur, MessageBoxButtons.OK, MessageBoxIcon.Exclamation)
                lockSectorLock.ReleaseMutex()
                Return False
            Finally
                If fileStream IsNot Nothing Then
                    fileStream.Close()
                    fileStream = Nothing
                End If
            End Try

            sectorsLocked.Add("Data\LockSecteur\" & fileName)
        Else
            Dim myFile As System.IO.FileInfo = New System.IO.FileInfo(fullDir & "\" & fileName)
            If myFile.Exists = True Then
                Try
                    fileStream = IO.File.Open(fullDir & "\" & fileName, IO.FileMode.Open, IO.FileAccess.Read, IO.FileShare.Delete)
                    Dim file As New IO.StreamReader(fileStream)
                    fileCurrentUser = file.ReadLine()
                    DateTemps = file.ReadLine()

                    If fileCurrentUser <> ConnectionsManager.currentUser Then Return False

                    myFile.Delete()
                Catch ex As Exception
                    'File already in use
                    lockSectorLock.ReleaseMutex()
                    Return False
                Finally
                    If fileStream IsNot Nothing Then
                        fileStream.Close()
                        fileStream = Nothing
                    End If
                End Try
            Else
                lockSectorLock.ReleaseMutex()
                Return False
            End If

            sectorsLocked.Remove("Data\LockSecteur\" & fileName)
        End If
        lockSectorLock.ReleaseMutex()

        Return True
    End Function

    Public Sub redirectSearchDB(ByVal searchDBFrom As Object, ByVal selectedItem() As InternalDBItem)
        Select Case searchDBFrom.Name.ToString.ToLower
            Case "commdate"
                Dim myComm() As String
                Dim fromForm As Form = CType(searchDBFrom, Control).FindForm
                Select Case True
                    Case fromForm.GetType.Equals(GetType(viewmodifclients))
                        With CType(fromForm, viewmodifclients)
                            Dim noCommunication As Integer = 0
                            If .listeCommunications.selected <> -1 Then noCommunication = .listeCommunications.ItemValueA(.listeCommunications.selected)
                            If noCommunication = 0 Then
                                MessageBox.Show("Impossible de lier l'item de la banque de données. Veuillez fermer le compte client, le rouvrir et recommencer. Merci!", "Erreur de communication")
                                Exit Sub
                            End If

                            myComm = Split(.listeCommunications.ItemValueB(.listeCommunications.selected), "§")
                            Dim fullPath As String = appPath & bar(appPath) & "Clients\" & .noClient & "\Comm\" & myComm(9).Substring(myComm(9).IndexOf("|") + 1)
                            If myComm(9) <> "" AndAlso IO.File.Exists(fullPath) AndAlso myComm(9).ToUpper.StartsWith("DB") = False Then IO.File.Delete(fullPath)

                            myComm(9) = "DB|" & selectedItem(0).noDBItem & "\" & selectedItem(0).getDBFolder.toString & "\" & selectedItem(0).dbItem
                            .listeCommunications.ItemValueB(.listeCommunications.selected) = Join(myComm, "§")
                            DBLinker.getInstance.updateDB("Communications", "NameOfFile='" & myComm(9).Replace("'", "''") & "'", "NoCommunication", noCommunication, False)
                            InternalUpdatesManager.getInstance.sendUpdate("AccountsCommunications(" & .noClient & "," & True & ")")
                        End With

                    Case fromForm.GetType.Equals(GetType(viewmodifKeyPeople))
                        With CType(fromForm, viewmodifKeyPeople)
                            Dim noCommunication As Integer = 0
                            If .listeCommunications.selected <> -1 Then noCommunication = .listeCommunications.ItemValueA(.listeCommunications.selected)
                            If noCommunication = 0 Then
                                MessageBox.Show("Impossible de lier l'item de la banque de données. Veuillez fermer le compte personne/organisme clé, le rouvrir et recommencer. Merci!", "Erreur de communication")
                                Exit Sub
                            End If

                            myComm = Split(.listeCommunications.ItemValueB(.listeCommunications.selected), "§")
                            Dim fullPath As String = appPath & bar(appPath) & "KP\" & .NoKP & "\Comm\" & myComm(9).Substring(myComm(9).IndexOf("|") + 1)
                            If myComm(9) <> "" AndAlso IO.File.Exists(fullPath) AndAlso myComm(9).ToUpper.StartsWith("DB") = False Then IO.File.Delete(fullPath)

                            myComm(9) = "DB|" & selectedItem(0).noDBItem & "\" & selectedItem(0).getDBFolder.toString & "\" & selectedItem(0).dbItem
                            .listeCommunications.ItemValueB(.listeCommunications.selected) = Join(myComm, "§")
                            DBLinker.getInstance.updateDB("CommunicationsKP", "NameOfFile='" & myComm(9).Replace("'", "''") & "'", "NoCommunication", noCommunication, False)
                            InternalUpdatesManager.getInstance.sendUpdate("AccountsCommunicationsKP(" & .NoKP & "," & True & ")")
                        End With
                End Select



            Case "addattach"
                With CType(searchDBFrom, Button)
                    For i As Integer = 0 To selectedItem.Length - 1
                        If TypeOf .FindForm Is msgSending Then CType(.FindForm, msgSending).Attachements.Text &= "DB:\" & selectedItem(i).noDBItem & "\" & selectedItem(i).getDBFolder.toString & "\" & selectedItem(i).dbItem & ";"
                        If TypeOf .FindForm Is MassMailing Then CType(.FindForm, MassMailing).Attachements.Text &= "DB:\" & selectedItem(i).noDBItem & "\" & selectedItem(i).getDBFolder.toString & "\" & selectedItem(i).dbItem & ";"
                    Next i
                End With

            Case Else
                If TypeOf searchDBFrom Is TextBox AndAlso TypeOf CType(searchDBFrom, TextBox).FindForm Is preferencesWin Then
                    CType(searchDBFrom, TextBox).Text = "DB:\" & selectedItem(0).uniqueNo & "\" & selectedItem(0).getDBFolder.toString & "\" & selectedItem(0).dbItem
                End If

                If TypeOf (searchDBFrom) Is InternalDBManager Then
                    Dim selectedStr As String = ""
                    For i As Integer = 0 To selectedItem.Length - 1
                        selectedStr = selectedStr & "§" & selectedItem(i).uniqueNo & "\" & selectedItem(i).getDBFolder.toString & "\" & selectedItem(i).dbItem
                    Next i
                    selectedStr = selectedStr.Substring(1)
                    With CType(searchDBFrom, InternalDBManager)
                        .foundItemFromDB = selectedStr
                    End With
                End If
        End Select
    End Sub

    Public Sub redirectAddressBook(ByVal abFrom As Object, ByVal itemPath As String, ByVal courriels() As String)
        If CType(abFrom, ManagedCombo).FindForm Is Nothing Then
            MessageBox.Show("La fenêtre ""Envoi d'un message"" a été fermée. Veuillez rouvrir cette fenêtre et recommencez.", "Fenêtre fermée")
            Exit Sub
        End If
        Select Case CType(abFrom, ManagedCombo).FindForm.Name.ToLower
            Case "msgsending"
                With CType(abFrom, ManagedCombo)
                    If .Text <> "" And Microsoft.VisualBasic.Right(.Text, 1) <> ";" Then .Text &= ";"
                    For Each curCourriel As String In courriels
                        If .Text.IndexOf(curCourriel & ";") = -1 Then .Text &= curCourriel & ";"
                    Next
                End With
        End Select
    End Sub

    Public Sub redirectSearch(ByVal searchFrom As Object, ByRef cancel As Boolean)
        If searchFrom Is Nothing Then Exit Sub 'No need to redirect

        'Try
        Select Case searchFrom.GetType.Name.ToLower
            Case "rapportgeneration"
                'Prise en charge dans la fenêtre

            Case "toolstripmenuitem"
                If searchFrom.text = "Ouvrir" Then openAccount(foundClient(foundClient.Length - 1).noClient)

            Case "addvisite"
                CType(searchFrom, addvisite).currentNoClient = foundClient(foundClient.Length - 1).noClient

            Case "addclient"
                With CType(searchFrom, addclient)
                    .unCheckMenus()
                    .menuRefCompte.Checked = True
                    .reference.Text = foundClient(foundClient.Length - 1).noClient & vbCrLf & foundClient(foundClient.Length - 1).fullName
                    .reference.Tag = "COMPTE"
                End With

            Case "viewmodifclients"
                With CType(searchFrom, viewmodifclients)
                    .uncheckMenus()
                    .menuRefCompte.Checked = True
                    .reference.Text = foundClient(foundClient.Length - 1).noClient & vbCrLf & foundClient(foundClient.Length - 1).fullName
                    .reference.Tag = "COMPTE"
                End With

            Case "addkeypeople"
                CType(searchFrom, addkeypeople).reference.Text = foundClient(foundClient.Length - 1).nam
                CType(searchFrom, addkeypeople).reference.Tag = foundClient(foundClient.Length - 1).noClient
                CType(searchFrom, addkeypeople).setFormModified = True

            Case "queuelist"
                CType(searchFrom, QueueList).addingClient = foundClient(foundClient.Length - 1).noClient

            Case "futurevisites"
                CType(searchFrom, FutureVisites).setRVClient(foundClient(foundClient.Length - 1).fullName, foundClient(foundClient.Length - 1).noClient)

            Case "msgsending"
                With CType(searchFrom, msgSending)
                    .AttachedCompte.Text = foundClient(UBound(foundClient)).fullName & " (" & foundClient(foundClient.Length - 1).noClient & ")"
                End With

            Case "msgcontact"
                With CType(searchFrom, msgContact)
                    .CompteRef.Text = foundClient(UBound(foundClient)).fullName & " (" & foundClient(foundClient.Length - 1).noClient & ")"
                    .setFormModified = True
                End With

            Case "textbox"
                Select Case CType(searchFrom, TextBox).Name.ToLower
                    Case "payeurclient"
                        With foundClient(foundClient.Length - 1)
                            searchFrom.text = .fullName & " (" & .noClient & ")"
                        End With

                    Case "entiteprimaire"
                        With foundClient(foundClient.Length - 1)
                            'REM_CODES
                            'REM This method should be changed... Should create a new method to chooseClient & Folder
                            Dim folders As DataSet = DBLinker.getInstance.readDBForGrid("SiteLesion RIGHT JOIN Infofolders ON SiteLesion.NoSiteLesion = Infofolders.NoSiteLesion", "Infofolders.NoFolder, SiteLesion.SiteLesion, Infofolders.NoCodeUnique", "WHERE ((Infofolders.NoClient)=" & .noClient & ");")
                            If folders Is Nothing OrElse folders.Tables.Count = 0 OrElse folders.Tables(0).Rows.Count = 0 Then
                                MessageBox.Show("Ce client n'a pas de dossier.Veuillez en choisir un autre", "Client sans dossier")
                                cancel = True
                                Exit Sub
                            End If
                            Dim foldersChoices As String = ""
                            For Each curRow As DataRow In folders.Tables(0).Rows
                                If foldersChoices <> "" Then foldersChoices &= "§"
                                Dim siteLesion As String = ""
                                If curRow("SiteLesion") IsNot DBNull.Value Then siteLesion = " - " & curRow("SiteLesion")
                                foldersChoices &= "#" & curRow("NoFolder") & siteLesion & " (" & Accounts.Clients.Folders.Codifications.FolderCodesManager.getInstance.getCodeNameByNoUnique(curRow("NoCodeUnique")) & ")"
                            Next
                            Dim myMultiChoice As New multichoice()
                            Dim myFolder As String = myMultiChoice.GetChoice("Veuillez choisir le dossier", foldersChoices, , "§")
                            If myFolder = "" Or myFolder.StartsWith("ERROR") Then Exit Sub

                            searchFrom.text = .fullName & " (" & .noClient & ") " & myFolder
                        End With
                End Select

            Case "listbox"
                With CType(searchFrom, ListBox)
                    Select Case .Name.ToLower
                        Case "dossier"
                            CType(.FindForm(), viewmodifclients).transferFolderNoClient = foundClient(foundClient.Length - 1).noClient
                    End Select
                End With
        End Select
        'Catch ex As Exception
        '    If SearchFrom Is Nothing Then
        '        MessageBox.Show("La fenêtre en lien avec la fenêtre de recherche a déjà été fermée", "Fenêtre fermée")
        '    Else
        '        MessageBox.Show("Une erreur est survenue. Veuillez contacter CyberInternautes.", "Erreur")
        '    End If
        '    AddErrorLog(ex)
        'End Try
    End Sub

    Public Function openUniqueWindow(Optional ByRef myForm As Object = Nothing, Optional ByVal caption As String = "", Optional ByVal startingWith As Boolean = False, Optional ByVal forceReload As Boolean = False, Optional ByVal hideSideBar As Boolean = True) As Form
        Dim i As Short

        If myMainWin Is Nothing Then Return myForm

        If hideSideBar Then myMainWin.barMainObjects.hideBar()

        With myMainWin.formOuvertes.items
            If caption <> "" Then
                For i = 0 To .Count - 1
                    Dim curWindow As SingleWindow = CType(.Item(i).ValueA, SingleWindow)
                    Try
                        With curWindow
                            If (startingWith = False And .Text = caption) Or (startingWith = True And .Text.StartsWith(caption) = True) Then
                                If .Name.ToUpper = "SEARCHDB" Then
                                    With CType(curWindow, SearchDB)
                                        .useWinAsSelection = False
                                    End With
                                ElseIf .Name.ToUpper = "ADDVISITE" Then
                                    With CType(curWindow, addvisite)
                                        .qlFrom = 0
                                    End With
                                End If
                                If forceReload = False Then
                                    Try
                                        If myForm IsNot Nothing Then CType(myForm, Form).Dispose()
                                    Catch 'REM Exception not handle
                                        'Ensure form exists and is not disposed
                                    End Try
                                    openedNewWindow = False
                                    .Select()
                                    If .WindowState = FormWindowState.Minimized Then .WindowState = FormWindowState.Normal
                                    Return curWindow
                                Else
                                    .Close()
                                    Exit For
                                End If
                            End If
                        End With
                    Catch ex As Exception
                        addErrorLog(New Exception("curWindow is Nothing=" & (curWindow Is Nothing) & ",.Item(i).Text=" & .Item(i).Text, ex))
                        Throw New AlreadyLoggedException(ex)
                    End Try
                Next i

                openedNewWindow = True
                Return myForm
            End If
            If Not myForm Is Nothing Then
                For i = 0 To .Count - 1
                    Dim curWindow As SingleWindow = CType(.Item(i).ValueA, SingleWindow)
                    With curWindow
                        If .GetType.Name = myForm.GetType.Name Then
                            If .Name.ToUpper = "SEARCHDB" Then
                                With CType(curWindow, SearchDB)
                                    .useWinAsSelection = False
                                End With
                            ElseIf .Name.ToUpper = "ADDVISITE" Then
                                With CType(curWindow, addvisite)
                                    .qlFrom = 0
                                End With
                            End If
                            If forceReload = False Then
                                If myForm IsNot Nothing Then CType(myForm, Form).Dispose()
                                openedNewWindow = False
                                .Select()
                                If .WindowState = FormWindowState.Minimized Then .WindowState = FormWindowState.Normal
                                Return curWindow
                            Else
                                .Close()
                                Exit For
                            End If
                        End If
                    End With
                Next i
            End If
        End With

        'No similar window founded
        openedNewWindow = True
        Return myForm
    End Function

    Public Sub changeCursor(ByRef myForm As Object, ByVal myCursor As Cursor)
        Dim i As Integer
        If myForm.GetType.Name.ToUpper = "TEXTBOX" And myCursor Is Cursors.Default Then
            myForm.cursor = Cursors.IBeam
        Else
            myForm.Cursor = myCursor
        End If

        For i = 0 To myForm.Controls.Count - 1
            If myForm.Controls(i).GetType.Name.ToUpper = "TEXTBOX" And myCursor Is Cursors.Default Then
                myForm.Controls(i).cursor = Cursors.IBeam
            Else
                myForm.Controls(i).Cursor = myCursor
            End If
            If myForm.Controls(i).Controls.Count > 0 Then changeCursor(myForm.Controls(i), myCursor)
        Next i
    End Sub

    Public Sub updateText(ByRef myForm As Form, ByVal newText As String)
        WindowsManager.getInstance.updateWindowText(myForm.Text, newText)
    End Sub
End Module
