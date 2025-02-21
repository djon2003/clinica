﻿Namespace ErrorTypes

    Public Class Step_AlreadyExists
        Inherits ErrorType

        Public Sub New(ByVal csstError As CSSTResponseError)
            MyBase.New(csstError)
        End Sub

        Private Shared CSST_ERROR_CODES() As String = {"MF10152E"}

        Public Overrides Sub manageError(ByVal input As ErrorInput)
            If input.out.newMarking > Params.current.markedAsConfirmed Then input.out.newMarking = Params.current.markedAsConfirmed

            input.out.fontColor = CsstTask.RESULT_INFO_COLOR
        End Sub

        Public Overloads Shared Function createErrorType(ByVal errorCode As CSSTResponseError) As ErrorType
            If Array.IndexOf(Of String)(CSST_ERROR_CODES, errorCode.ToString()) = -1 Then Return Nothing

            Return New Step_AlreadyExists(errorCode)
        End Function
    End Class

End Namespace
