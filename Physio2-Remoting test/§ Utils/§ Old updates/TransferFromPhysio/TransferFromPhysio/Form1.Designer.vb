<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class Form1
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub initializeComponent()
        Dim dataGridViewCellStyle1 As System.Windows.Forms.DataGridViewCellStyle = New System.Windows.Forms.DataGridViewCellStyle
        Dim dataGridViewCellStyle2 As System.Windows.Forms.DataGridViewCellStyle = New System.Windows.Forms.DataGridViewCellStyle
        Me.Button1 = New System.Windows.Forms.Button
        Me.DataGridView1 = New System.Windows.Forms.DataGridView
        Me.Client = New System.Windows.Forms.CheckBox
        Me.Label1 = New System.Windows.Forms.Label
        Me.erreurs = New System.Windows.Forms.TextBox
        Me.medecins = New System.Windows.Forms.CheckBox
        Me.Clinique = New System.Windows.Forms.CheckBox
        Me.Users = New System.Windows.Forms.CheckBox
        Me.OpenFileDialog1 = New System.Windows.Forms.OpenFileDialog
        Me.Button2 = New System.Windows.Forms.Button
        Me.RVs = New System.Windows.Forms.CheckBox
        Me.scripting = New System.Windows.Forms.CheckBox
        Me.mapfromfile = New System.Windows.Forms.CheckBox
        Me.dataDate = New System.Windows.Forms.TextBox
        Me.Label2 = New System.Windows.Forms.Label
        CType(Me.DataGridView1, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'Button1
        '
        Me.Button1.Location = New System.Drawing.Point(12, 2)
        Me.Button1.Name = "Button1"
        Me.Button1.Size = New System.Drawing.Size(75, 23)
        Me.Button1.TabIndex = 0
        Me.Button1.Text = "Extract"
        Me.Button1.UseVisualStyleBackColor = True
        '
        'DataGridView1
        '
        Me.DataGridView1.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
                    Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        DataGridViewCellStyle1.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft
        DataGridViewCellStyle1.BackColor = System.Drawing.SystemColors.Control
        DataGridViewCellStyle1.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        DataGridViewCellStyle1.ForeColor = System.Drawing.SystemColors.WindowText
        DataGridViewCellStyle1.SelectionBackColor = System.Drawing.SystemColors.Highlight
        DataGridViewCellStyle1.SelectionForeColor = System.Drawing.SystemColors.HighlightText
        DataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.[True]
        Me.DataGridView1.ColumnHeadersDefaultCellStyle = DataGridViewCellStyle1
        Me.DataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize
        DataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft
        DataGridViewCellStyle2.BackColor = System.Drawing.SystemColors.Window
        DataGridViewCellStyle2.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        DataGridViewCellStyle2.ForeColor = System.Drawing.SystemColors.ControlText
        DataGridViewCellStyle2.SelectionBackColor = System.Drawing.SystemColors.Highlight
        DataGridViewCellStyle2.SelectionForeColor = System.Drawing.SystemColors.HighlightText
        DataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.[False]
        Me.DataGridView1.DefaultCellStyle = DataGridViewCellStyle2
        Me.DataGridView1.Location = New System.Drawing.Point(12, 41)
        Me.DataGridView1.Name = "DataGridView1"
        Me.DataGridView1.Size = New System.Drawing.Size(563, 182)
        Me.DataGridView1.TabIndex = 1
        '
        'Client
        '
        Me.Client.AutoSize = True
        Me.Client.Location = New System.Drawing.Point(316, 6)
        Me.Client.Name = "Client"
        Me.Client.Size = New System.Drawing.Size(52, 17)
        Me.Client.TabIndex = 2
        Me.Client.Text = "Client"
        Me.Client.UseVisualStyleBackColor = True
        Me.Client.Checked = True
        '
        'Label1
        '
        Me.Label1.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.Label1.AutoSize = True
        Me.Label1.Location = New System.Drawing.Point(9, 226)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(40, 13)
        Me.Label1.TabIndex = 3
        Me.Label1.Text = "Erreurs"
        '
        'erreurs
        '
        Me.erreurs.Anchor = CType(((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.erreurs.Location = New System.Drawing.Point(12, 242)
        Me.erreurs.Multiline = True
        Me.erreurs.Name = "erreurs"
        Me.erreurs.ScrollBars = System.Windows.Forms.ScrollBars.Both
        Me.erreurs.Size = New System.Drawing.Size(563, 71)
        Me.erreurs.TabIndex = 4
        '
        'medecins
        '
        Me.medecins.AutoSize = True
        Me.medecins.Location = New System.Drawing.Point(226, 6)
        Me.medecins.Name = "medecins"
        Me.medecins.Size = New System.Drawing.Size(72, 17)
        Me.medecins.TabIndex = 2
        Me.medecins.Text = "M�decins"
        Me.medecins.UseVisualStyleBackColor = True
        Me.medecins.Checked = True
        '
        'Clinique
        '
        Me.Clinique.AutoSize = True
        Me.Clinique.Location = New System.Drawing.Point(93, 6)
        Me.Clinique.Name = "Clinique"
        Me.Clinique.Size = New System.Drawing.Size(63, 17)
        Me.Clinique.TabIndex = 2
        Me.Clinique.Text = "Clinique"
        Me.Clinique.UseVisualStyleBackColor = True
        Me.Clinique.Checked = True
        '
        'Users
        '
        Me.Users.AutoSize = True
        Me.Users.Location = New System.Drawing.Point(153, 6)
        Me.Users.Name = "Users"
        Me.Users.Size = New System.Drawing.Size(77, 17)
        Me.Users.TabIndex = 2
        Me.Users.Text = "Utilisateurs"
        Me.Users.UseVisualStyleBackColor = True
        Me.Users.Checked = True
        '
        'OpenFileDialog1
        '
        Me.OpenFileDialog1.FileName = "physio.mdb"
        Me.OpenFileDialog1.InitialDirectory = "C:\PHYSIO\AGENDA1"
        Me.OpenFileDialog1.Filter = "Fichiers Access|*.mdb"
        '
        'Button2
        '
        Me.Button2.Location = New System.Drawing.Point(518, 2)
        Me.Button2.Name = "Button2"
        Me.Button2.Size = New System.Drawing.Size(57, 31)
        Me.Button2.TabIndex = 5
        Me.Button2.Text = "Quit"
        Me.Button2.UseVisualStyleBackColor = True
        '
        'RVs
        '
        Me.RVs.AutoSize = True
        Me.RVs.Location = New System.Drawing.Point(399, 6)
        Me.RVs.Name = "RVs"
        Me.RVs.Size = New System.Drawing.Size(46, 17)
        Me.RVs.TabIndex = 2
        Me.RVs.Text = "RVs"
        Me.RVs.UseVisualStyleBackColor = True
        Me.RVs.Checked = True
        '
        'scripting
        '
        Me.scripting.AutoSize = True
        Me.scripting.Location = New System.Drawing.Point(399, 22)
        Me.scripting.Name = "scripting"
        Me.scripting.Size = New System.Drawing.Size(105, 17)
        Me.scripting.TabIndex = 2
        Me.scripting.Text = "Scripting method"
        Me.scripting.UseVisualStyleBackColor = True
        '
        'mapfromfile
        '
        Me.mapfromfile.AutoSize = True
        Me.mapfromfile.Location = New System.Drawing.Point(316, 22)
        Me.mapfromfile.Name = "mapfromfile"
        Me.mapfromfile.Size = New System.Drawing.Size(86, 17)
        Me.mapfromfile.TabIndex = 2
        Me.mapfromfile.Text = "Map from file"
        Me.mapfromfile.UseVisualStyleBackColor = True
        '
        'dataDate
        '
        Me.dataDate.Location = New System.Drawing.Point(210, 22)
        Me.dataDate.Name = "dataDate"
        Me.dataDate.Size = New System.Drawing.Size(100, 20)
        Me.dataDate.TabIndex = 6
        Me.dataDate.Text = "2008-03-31"
        '
        'Label2
        '
        Me.Label2.AutoSize = True
        Me.Label2.Location = New System.Drawing.Point(130, 26)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(74, 13)
        Me.Label2.TabIndex = 7
        Me.Label2.Text = "Date donn�es"
        '
        'Form1
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(587, 325)
        Me.Controls.Add(Me.Label2)
        Me.Controls.Add(Me.dataDate)
        Me.Controls.Add(Me.scripting)
        Me.Controls.Add(Me.RVs)
        Me.Controls.Add(Me.Button2)
        Me.Controls.Add(Me.erreurs)
        Me.Controls.Add(Me.Label1)
        Me.Controls.Add(Me.medecins)
        Me.Controls.Add(Me.Users)
        Me.Controls.Add(Me.Clinique)
        Me.Controls.Add(Me.mapfromfile)
        Me.Controls.Add(Me.Client)
        Me.Controls.Add(Me.DataGridView1)
        Me.Controls.Add(Me.Button1)
        Me.Name = "Form1"
        Me.Text = "Extraction de Physio vers Clinica"
        CType(Me.DataGridView1, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents Button1 As System.Windows.Forms.Button
    Friend WithEvents DataGridView1 As System.Windows.Forms.DataGridView
    Friend WithEvents Client As System.Windows.Forms.CheckBox
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents erreurs As System.Windows.Forms.TextBox
    Friend WithEvents medecins As System.Windows.Forms.CheckBox
    Friend WithEvents Clinique As System.Windows.Forms.CheckBox
    Friend WithEvents Users As System.Windows.Forms.CheckBox
    Friend WithEvents OpenFileDialog1 As System.Windows.Forms.OpenFileDialog
    Friend WithEvents Button2 As System.Windows.Forms.Button
    Friend WithEvents RVs As System.Windows.Forms.CheckBox
    Friend WithEvents scripting As System.Windows.Forms.CheckBox
    Friend WithEvents mapfromfile As System.Windows.Forms.CheckBox
    Friend WithEvents dataDate As System.Windows.Forms.TextBox
    Friend WithEvents Label2 As System.Windows.Forms.Label

End Class
