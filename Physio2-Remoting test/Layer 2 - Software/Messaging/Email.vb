Imports System.Net.Mime

Public Class Email
    Private Sub New()
    End Sub

    Private Const HEADER_CONTENT_DESCRIPTION As String = "content-description"

    Private headerToConvert As New Generic.List(Of String)
    Private mediaTypesToSkipForAttachment() As String = {"message/delivery-status", "message/report", "message/disposition-notification"}

    Public Sub New(ByVal serverIdent As String, ByVal pop3Server As String, ByVal pop3User As String)
        headerToConvert.AddRange(New String() {"to", "from", "envelope-to", "return-path", "subject"})

        Me.serverIdent = serverIdent
        Me.pop3Server = pop3Server
        Me.pop3User = pop3User
    End Sub

    Public Class EmailPart
        Public type As ContentType
        Public infos As New Hashtable
        Public content As String = ""

        Public Sub New(ByVal type As ContentType)
            Me.type = type
        End Sub

        Public Sub New(ByVal contentType As String)
            Me.type = New ContentType(contentType)
        End Sub
    End Class

    Private _MainType As ContentType
    Private serverIdent As String = ""
    Private pop3Server As String = ""
    Private pop3User As String = ""
    Private source As String = ""
    Public headerInfos As New Hashtable
    Public emailParts As System.Collections.Generic.List(Of EmailPart)

#Region "Properties"
    Public Property mainType() As ContentType
        Get
            Return _MainType
        End Get
        Set(ByVal value As ContentType)
            _MainType = value
        End Set
    End Property
#End Region

    Public Function getHeaderValue(ByVal key As String, ByVal headerInfos As Hashtable) As String
        If headerInfos.ContainsKey(key) = False Then Return ""

        Return headerInfos(key.ToLower)
    End Function

    Public Sub extractFromSource(ByVal sourceBytes() As Byte)
        Dim source As String = System.Text.Encoding.GetEncoding("latin1").GetString(sourceBytes)
        If source.IndexOf("Ã©") <> -1 OrElse source.IndexOf("Ã¨") <> -1 Then source = System.Text.Encoding.GetEncoding("utf-8").GetString(sourceBytes)
        If source.IndexOf("�") <> -1 Then source = System.Text.Encoding.GetEncoding("iso-8859-1").GetString(sourceBytes)

        Me.source = source

        source &= vbCrLf
        Dim endLineIndex As Integer = source.LastIndexOf(vbCrLf & "." & vbCrLf)
        If endLineIndex <> -1 Then source = source.Substring(0, endLineIndex)

        Me.source = source

        emailParts = New System.Collections.Generic.List(Of EmailPart)
        internalExtractFromSource(source, Me.headerInfos)

        For i As Integer = 0 To emailParts.Count - 1
            Dim contentType As String = ""
            Dim transferEncoding As String = Me.getHeaderValue("content-transfer-encoding", emailParts(i).infos)

            If transferEncoding <> "base64" AndAlso emailParts(i).content <> "" AndAlso emailParts(i).type.CharSet IsNot Nothing Then
                Dim content As String = emailParts(i).content
                content = convertFrom(emailParts(i).content, emailParts(i).type.CharSet)
                content = convertFromHexadecimal(emailParts(i).content, emailParts(i).type.CharSet)

                'Remove <meta> tags so that content-type doesn't interfere with transformation
                If emailParts(i).type.MediaType.ToLower = "text/html" Then content = System.Text.RegularExpressions.Regex.Replace(content, "\<meta [^>]+\>", "", System.Text.RegularExpressions.RegexOptions.IgnoreCase)

                emailParts(i).content = content
            End If
        Next i
    End Sub

    Private multipartReportTextDone As Boolean = False

    Private Sub internalExtractFromSource(ByVal source As String, ByVal enteteInfos As Hashtable, Optional ByVal addEmailPartOnNoBoundary As Boolean = True)
        Dim curSource As String = source.Replace(vbTab, " ").Replace(Chr(10), "") '.Replace(vbLf & vbLf, vbLf)
        enteteInfos.Clear()
        Dim linesReponse() As String = curSource.Split(New Char() {vbCrLf})
        Dim etape As Byte = 1
        Dim curContent_boundary As ContentType = Nothing
        Dim mainContent_boundary As ContentType = Nothing
        Dim eiKey As String = ""
        Dim curContent As New System.Text.StringBuilder
        For l As Integer = 0 To linesReponse.GetUpperBound(0)
            If linesReponse(l) = "." Then Exit For 'Over end (???)

            Select Case etape
                Case 1 'Entête
                    If enteteInfos.Count = 0 AndAlso linesReponse(l).Trim = "" Then Exit Select

                    'REM '' CODE DESACTIVATED -> Otherwise, the text part contains headers which is not desired... I know that this code was there to fix a bug, but it was not written what neither why. So, keeping it in case I find later what it was usefully to and a better way to fix it.
                    ''If mainType is "multipart/report" then skip to step 3 and return one line back (so this line will be taken)
                    'If Not multipartReportTextDone AndAlso Me.mainType IsNot Nothing AndAlso Me.mainType.MediaType = "multipart/report" Then
                    '    multipartReportTextDone = True

                    '    etape = 3
                    '    l -= 1

                    '    Dim emailPart As New EmailPart("text/plain")
                    '    emailParts.Add(emailPart)

                    '    Exit Select
                    'End If

                    If linesReponse(l).Length <> 0 AndAlso System.Text.RegularExpressions.Regex.Replace(linesReponse(l).Substring(0, 1), "[^a-z]", "", System.Text.RegularExpressions.RegexOptions.IgnoreCase) = "" Then
                        If enteteInfos.Count = 0 Then Exit Select

                        enteteInfos(eiKey) &= linesReponse(l).Replace(vbLf, "").Replace(vbCr, "")

                        If linesReponse(l + 1) = "" Then etape = 2
                        Exit Select
                    End If

                    Dim slr() As String = linesReponse(l).Split(New Char() {":"}, 2)
                    eiKey = slr(0).Trim.Replace(vbLf, "").Replace(vbCr, "").ToLower
                    If enteteInfos.ContainsKey(eiKey) Then
                        enteteInfos(eiKey) &= vbCrLf & linesReponse(l).Replace(vbLf, "").Replace(vbCr, "")
                    Else
                        enteteInfos.Add(eiKey, slr(1).Replace(vbLf, "").Replace(vbCr, "").Trim)
                    End If

                    If linesReponse(l + 1).Trim() = String.Empty Then etape = 2


                Case 2 'Recherche de séparateur
                    Dim contentType As String = getHeaderValue("content-type", enteteInfos).Replace(vbCrLf, "")
                    If contentType = "" Then contentType = "text/plain"
                    If mainContent_boundary Is Nothing Then
                        Try
                            mainContent_boundary = New ContentType(contentType)
                        Catch ex As Exception
                            'Trying to fix a bug
                            Throw New Exception("contentType=" & contentType, ex)
                        End Try
                        curContent_boundary = mainContent_boundary
                    End If
                    If _MainType Is Nothing Then _MainType = mainContent_boundary

                    If curContent_boundary.Boundary Is Nothing OrElse curContent_boundary.Boundary = "" Then
                        etape = 3
                        If addEmailPartOnNoBoundary Then
                            Dim ep As New EmailPart(curContent_boundary)
                            ep.infos = enteteInfos
                            emailParts.Add(ep)
                        Else
                            emailParts(emailParts.Count - 1).type = curContent_boundary
                        End If
                        Exit Select
                    End If

                    Dim parts() As String = curSource.Split(New String() {"--" & curContent_boundary.Boundary}, StringSplitOptions.None)
                    For i As Integer = 1 To parts.GetUpperBound(0)
                        If parts(i).Trim.Replace(vbLf, "").Replace(vbCr, "").Replace("-", "") = "." Then etape = 4

                        Dim emailPart As New EmailPart(curContent_boundary)
                        emailParts.Add(emailPart)
                        internalExtractFromSource(parts(i), emailPart.infos, False)
                    Next i

                    etape = 4

                Case 3 'Rempli le contenu ligne par ligne
                    With emailParts(emailParts.Count - 1)
                        If linesReponse(l) = "" AndAlso Me.getHeaderValue("content-transfer-encoding", enteteInfos).IndexOf("base64") <> -1 Then
                            .content = curContent.ToString
                            etape = 4
                            Exit Select
                        End If
                        If linesReponse(l).Trim = "." Then
                            If curContent.Length <> 0 Then
                                .content = curContent.ToString
                                .content = .content.Substring(0, .content.LastIndexOf(vbCrLf))
                            End If
                            etape = 4
                            Exit Select
                        End If

                        curContent.AppendLine(linesReponse(l))
                    End With
                Case 4
                    Exit For
            End Select
        Next l

        Dim tmpInfos As Hashtable = enteteInfos.Clone
        Dim curCharset As String = Me.mainType.CharSet
        If emailParts.Count <> 0 Then
            curCharset = emailParts(emailParts.Count - 1).type.CharSet
        End If
        For Each curKey As String In enteteInfos.Keys
            If headerToConvert.Contains(curKey) = False Then Continue For

            tmpInfos(curKey) = convertFrom(tmpInfos(curKey))
            tmpInfos(curKey) = convertFromHexadecimal(tmpInfos(curKey), curCharset)
            tmpInfos(curKey) = convertFromHexadecimal(tmpInfos(curKey), "us-ascii")
            tmpInfos(curKey) = tmpInfos(curKey).ToString.Replace("""", "")
        Next

        If emailParts.Count <> 0 Then
            With emailParts(emailParts.Count - 1)
                If .content = "" Then .content = curContent.ToString
                .infos = tmpInfos.Clone
            End With

            If enteteInfos.Equals(Me.headerInfos) Then Me.headerInfos = tmpInfos.Clone()
        Else
            Me.headerInfos = tmpInfos.Clone
        End If
    End Sub

    Public Function getMessage() As String
        Dim textBody As String = ""
        Dim htmlBody As String = ""
        For i As Integer = 0 To emailParts.Count - 1
            If textBody = "" AndAlso emailParts(i).type.MediaType = "text/plain" Then
                'Content-Transfer-Encoding
                textBody = emailParts(i).content
                If Me.getHeaderValue("content-transfer-encoding", emailParts(i).infos).IndexOf("base64") <> -1 Then
                    If emailParts(i).type.CharSet IsNot Nothing Then
                        textBody = System.Text.Encoding.GetEncoding(emailParts(i).type.CharSet).GetString(convertFromBase64(emailParts(i).content))
                    Else
                        textBody = convertFromBase64(emailParts(i).content, True)
                    End If
                End If
                textBody = textBody.Replace(vbCrLf, "<br>")
            End If
            If htmlBody = "" AndAlso emailParts(i).type.MediaType = "text/html" Then
                If Me.getHeaderValue("content-transfer-encoding", emailParts(i).infos).IndexOf("base64") <> -1 Then
                    If emailParts(i).type.CharSet IsNot Nothing Then
                        htmlBody = System.Text.Encoding.GetEncoding(emailParts(i).type.CharSet).GetString(convertFromBase64(emailParts(i).content))
                    Else
                        htmlBody = convertFromBase64(emailParts(i).content, True)
                    End If
                Else
                    htmlBody = emailParts(i).content
                End If

                htmlBody = System.Text.RegularExpressions.Regex.Replace(htmlBody, "\<meta http-equiv=""Content-Type""([^>])+\>", "", System.Text.RegularExpressions.RegexOptions.IgnoreCase)
                htmlBody = System.Text.RegularExpressions.Regex.Replace(htmlBody, "\<script ([^>])+\>", "", System.Text.RegularExpressions.RegexOptions.IgnoreCase)
                htmlBody = System.Text.RegularExpressions.Regex.Replace(htmlBody, "\<link ([^>])+\/\>", "", System.Text.RegularExpressions.RegexOptions.IgnoreCase)
                htmlBody = System.Text.RegularExpressions.Regex.Replace(htmlBody, "\<\/script\>", "", System.Text.RegularExpressions.RegexOptions.IgnoreCase)
            End If
        Next i

        If htmlBody = "" Then htmlBody = textBody

        Return htmlBody
    End Function

    Public Sub save(ByVal noUser As Integer)
        Dim savingFolder As MailFolder = MailsManager.getInstance.getMailFolder(MailFolder.getPath(noUser, ""))
        Dim testFeedback As Boolean = Me.getHeaderValue("disposition-notification-to", Me.headerInfos) <> "" OrElse Me.getHeaderValue("return-receipt-to", Me.headerInfos) <> ""
        Dim feedBackSent As String = IIf(testFeedback, "0", "1")
        Dim noMail As Integer = 0
        Dim sentDate As Date = getSentDate()

        Dim message As String = getMessage()
        Dim toField As String = Me.getHeaderValue("to", Me.headerInfos)
        If toField = "" Then toField = Me.getHeaderValue("envelope-to", Me.headerInfos)

        DBLinker.getInstance.writeDB("Mails", "NoMailFolder,[From],CC,[To],NoUserTo,AffDate,Subject,IsRead,Message,FilesAttached,HasSentFeedBack,Source,POPServer,ServerIdent,POPUser", savingFolder.noMailFolder & ",'" & Me.getHeaderValue("from", Me.headerInfos).Replace("'", "''") & "','" & Me.getHeaderValue("cc", Me.headerInfos).Replace("'", "''") & "','" & toField.Replace("'", "''") & "'," & IIf(noUser = 0, "null", noUser) & ",'" & DateFormat.getTextDate(sentDate) & " " & DateFormat.getTextDate(sentDate, DateFormat.TextDateOptions.FullTime) & "','" & Me.getHeaderValue("subject", Me.headerInfos).Replace("'", "''") & "',0,'" & message.Replace("'", "''") & "',''," & feedBackSent & ",'" & Me.source.Replace("'", "''") & "','" & Me.pop3Server.Replace("'", "''") & "','" & Me.serverIdent.Replace("'", "''") & "','" & Me.pop3User.Replace("'", "''") & "'", , , , noMail)

        saveAttachments(noMail, message)
    End Sub

    Private Function getSentDate() As Date
        Dim dateEntry As String = Me.getHeaderValue("delivery-date", Me.headerInfos)
        If dateEntry = "" Then dateEntry = Me.getHeaderValue("date", Me.headerInfos)

        dateEntry = System.Text.RegularExpressions.Regex.Replace(dateEntry, " \([^()]+\)", "")
        Dim sDate() As String = dateEntry.Split(" ")
        Dim sentDate As Date = Date.Now
        If Date.TryParse(dateEntry, sentDate) Then
            Dim diffHoursOfSentDateFromUTC As Integer = 0

            If sDate.Length = 6 AndAlso sDate(4) = sentDate.TimeOfDay.ToString() AndAlso Integer.TryParse(sDate(5).Substring(0, sDate(5).Length - 2), diffHoursOfSentDateFromUTC) Then
                'Correct time upon timezone
                sentDate = sentDate.AddHours(Date.Now.Subtract(Date.UtcNow).Hours - diffHoursOfSentDateFromUTC)
            End If
        End If

        Return sentDate
    End Function

    Private Function isAcceptedAttachment(ByVal emailPart As EmailPart) As Boolean
        If emailPart.infos.ContainsKey(HEADER_CONTENT_DESCRIPTION) AndAlso emailPart.infos(HEADER_CONTENT_DESCRIPTION).ToString().Trim().ToLower() = "notification" Then Return False

        Dim mediaType As String = emailPart.type.MediaType
        For Each curMediaType As String In mediaTypesToSkipForAttachment
            If curMediaType.ToLower() = mediaType.ToLower() Then Return False
        Next

        Return True
    End Function

    Private Sub saveAttachments(ByVal noMail As Integer, ByVal message As String)
        Dim myPath As String = appPath & bar(appPath) & "Data\Mails\" & noMail & "\attach"
        IO.Directory.CreateDirectory(myPath)
        Dim filesAttached As String = ""
        Dim changesToSave As Boolean = False
        For i As Integer = 0 To emailParts.Count - 1
            If emailParts(i).content <> "" AndAlso isAcceptedAttachment(emailParts(i)) Then
                Dim contentId As String = ""
                If emailParts(i).infos.ContainsKey("content-id") Then contentId = emailParts(i).infos("content-id").ToString.Replace("<", "").Replace(">", "")

                Dim inLineFile As Boolean = False
                Dim filename As String = getAttachmentFilename(emailParts(i), contentId, inLineFile)
                If filename Is Nothing OrElse filename = "inline" OrElse filename = String.Empty Then Continue For

                Dim extension As String = filename.Substring(filename.LastIndexOf(".") + 1)
                Dim fileNo As Integer = genUniqueNo()
                If Not inLineFile Then filesAttached &= "§FILE|" & filename & "|" & fileNo & "." & extension
                If emailParts(i).infos.ContainsValue("base64") Then
                    Try
                        Dim attachBytes() As Byte = convertFromBase64(emailParts(i).content)
                        IO.File.WriteAllBytes(myPath & "\" & fileNo & "." & extension, attachBytes)
                    Catch ex As Exception
                        Throw New Exception("filename=" & filename & vbCrLf & "Mail source:" & vbCrLf & source, ex)
                    End Try
                Else
                    IO.File.WriteAllText(myPath & "\" & fileNo & "." & extension, emailParts(i).content)
                End If

                If contentId <> "" Then
                    message = message.Replace("cid:" & contentId, myPath & "\" & fileNo & "." & extension)
                End If

                changesToSave = True
            End If
        Next i

        If changesToSave Then
            If filesAttached <> "" Then filesAttached = filesAttached.Substring(1)
            DBLinker.getInstance.updateDB("Mails", "Message='" & message.Replace("'", "''") & "', FilesAttached='" & filesAttached.Replace("'", "''") & "'", "NoMail", noMail, False)
        End If
    End Sub

    Private Function trimAttachmentFilename(ByVal filenameData As String) As String
        Dim filenamePos As Integer = filenameData.IndexOf("name=")
        Dim partLengthIndex As Integer = 0
        If filenamePos = -1 Then
            partLengthIndex = 1
            filenamePos = filenameData.IndexOf("name*=")
            If filenamePos = -1 Then
                partLengthIndex = 2
                filenamePos = filenameData.IndexOf("name*0*=")
            End If
        End If

        If filenamePos = -1 Then Return Nothing

        Dim filename As String = String.Empty
        Dim charset As String = String.Empty
        Dim nbStars As Integer = 2
        While filenamePos <> -1
            'Adjust filenamePos to first char of filename part
            filenamePos += 5 'String "name" and "="
            If partLengthIndex < 2 Then
                filenamePos += partLengthIndex
            Else
                filenamePos += Math.Ceiling((partLengthIndex - 2) / 10 + 0.0000001) + nbStars 'Place cursor to start of charset
            End If

            If partLengthIndex = 1 OrElse partLengthIndex = 2 Then
                Dim endCharsetPos As Integer = filenameData.IndexOf("'", filenamePos) 'Find end of charset / begin of language part
                charset = filenameData.Substring(filenamePos, endCharsetPos - filenamePos).Trim() 'Extract charset
                charset = charset.Replace("""", "") 'Remove possible useless char
                filenamePos = filenameData.IndexOf("'", endCharsetPos + 1) + 1 'Goto end of language part
            End If

            'Set next part index (if exists)
            partLengthIndex += 1
            nbStars = 2
            Dim nextFilenamePos As Integer = filenameData.IndexOf("name*" & partLengthIndex - 2 & "*=")
            If nextFilenamePos = -1 Then
                nbStars = 1
                nextFilenamePos = filenameData.IndexOf("name*" & partLengthIndex - 2 & "=")
            End If

            'Extract filename part
            filename = filename & filenameData.Substring(filenamePos).Trim()
            Dim filenameEndPosAfter As Integer = 0
            If filename.StartsWith("""") Then
                filenameEndPosAfter = filename.IndexOf("""", 1)
            End If
            If filename.IndexOf(";", filenameEndPosAfter) <> -1 Then
                filename = filename.Substring(0, filename.IndexOf(";", filenameEndPosAfter))
                filename = filename.Trim.Replace("""", "")
            ElseIf nextFilenamePos <> -1 Then
                filename = filename.Substring(0, nextFilenamePos)
                filename = filename.Substring(0, filename.LastIndexOf(" "))
            End If

            filenamePos = nextFilenamePos
        End While

        If charset <> String.Empty Then
            filename = convertFromHexadecimal(filename, charset, "%")
        End If

        Return filename
    End Function

    Private Function getAttachmentFilename(ByVal emailPart As EmailPart, ByVal contentId As String, ByRef inLineFile As Boolean) As String
        Dim filename As String = emailPart.infos("content-disposition")
        If filename = "inline" Then Return filename

        If emailPart.type.MediaType = "message/rfc822" Then
            filename = "Courriel retourné.eml"
        ElseIf filename Is Nothing OrElse filename = "" Then
            filename = emailPart.infos(HEADER_CONTENT_DESCRIPTION)
        Else
            filename = trimAttachmentFilename(filename)
        End If

        If filename Is Nothing OrElse filename = "" Then
            filename = emailPart.infos("content-type")

            If filename Is Nothing Then Return Nothing

            If filename.IndexOf("name=") <> -1 Then
                filename = trimAttachmentFilename(filename)
            Else
                If emailPart.type.MediaType.ToLower() = "text/html" OrElse emailPart.type.MediaType.ToLower() = "text/plain" Then
                    filename = String.Empty
                Else
                    Dim extByMime As String = emailPart.type.getMimeExtension()

                    If extByMime Is Nothing Then
                        filename = filename.Substring(filename.IndexOf("/") + 1)
                        If filename.Length > 3 Then filename = filename.Substring(0, 3)
                        filename = "." & filename
                        If contentId <> "" Then
                            filename = "<" & contentId & ">" & filename
                            inLineFile = True
                        Else
                            filename = "Nom inconnu" & filename
                        End If
                    Else
                        filename = "Nom inconnu." & extByMime
                    End If
                End If
            End If
        End If

        'Transpose from specific encoding
        Dim encodedPos As Integer = filename.IndexOf("=?")
        If encodedPos <> -1 Then
            Dim encoding As String = filename.Substring(encodedPos + 2)
            encoding = encoding.Substring(0, encoding.IndexOf("?"))
            filename = convertFrom(filename, encoding)
        End If

        If filename.StartsWith("""") OrElse filename.StartsWith("'") Then
            filename = filename.Substring(1)
        End If
        If filename.EndsWith("""") OrElse filename.EndsWith("'") Then
            filename = filename.Substring(0, filename.Length - 1)
        End If

        Return Fichiers.replaceIllegalChars(filename)
    End Function

    Protected Overrides Sub Finalize()
        MyBase.Finalize()
    End Sub
End Class
