Public Class UserAlreadyUsingException
    Inherits Exception

    Public Sub New(ByVal message As String)
        MyBase.New(message)
    End Sub

End Class
