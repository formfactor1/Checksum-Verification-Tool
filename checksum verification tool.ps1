<#
Checksum Verification Tool
.Description
Powershell, form based gui, that calculates the MD5 and SHA1 checksum of a file(s).
.How to use
Run the script and then drag and drop a file into the gui. 
Check the box for MD5 or SHA1 then click compare.
.Created by
Nathan Studebaker
#>
### Create the form ###
Add-Type -AssemblyName System.Windows.Forms
$form = New-Object System.Windows.Forms.Form
$form.Text = "Checksum Verification Tool"
$form.Size = '420,480'
$form.StartPosition = "CenterScreen"
$form.MinimumSize = $form.Size
$form.MaximizeBox = $False
$form.Topmost = $True

### Define controls ###

$button = New-Object System.Windows.Forms.Button
$button.Location = '5,5'
$button.Size = '75,23'
$button.Width = 120
$button.Text = "Compare"

$checkbox = New-Object Windows.Forms.Checkbox
$checkbox.Location = '140,8'
$checkbox.AutoSize = $True
$checkbox.Text = "Clear Results"

$label = New-Object Windows.Forms.Label
$label.Location = '5,40'
$label.AutoSize = $True
$label.Text = "Drag and drop the file here to calculate the checksum:"

$listBox = New-Object Windows.Forms.ListBox
$listBox.Location = '5,60'
$listBox.Height = 175
$listBox.Width = 340
$listBox.Anchor = ([System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Top)
$listBox.IntegralHeight = $False
$listBox.AllowDrop = $True

$chklabel = New-Object Windows.Forms.Label
$chklabel.Location = '5,250'
$chklabel.AutoSize = $True
$chklabel.Anchor = ([System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Bottom)
$chklabel.Text = "Paste the published checksum value here:"

$textBox = New-Object Windows.Forms.TextBox
$textBox.Location = '5,270'
$textBox.Height = 25
$textBox.Width = 340
$textBox.Anchor = ([System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Bottom)
#$textBox.IntegralHeight = $False
$textBox.AllowDrop = $True

$statusBar = New-Object System.Windows.Forms.StatusBar
$statusBar.Text = "Ready"

$md5checkbox = New-Object Windows.Forms.Checkbox
$md5checkbox.Location = '250,8'
$md5checkbox.AutoSize = $True
$md5checkbox.Text = "MD5"

$sha1checkbox = New-Object Windows.Forms.Checkbox
$sha1checkbox.Location = '300,8'
$sha1checkbox.AutoSize = $True
$sha1checkbox.Text = "SHA1"

$label = New-Object Windows.Forms.Label
$label.Location = '5,350'
$label.AutoSize = $True
$label.Text = "MD5 checksums should be in the XX-XX-XX... format."

### Add controls to form ###
$form.SuspendLayout()
$form.Controls.Add($button)
$form.Controls.Add($checkbox)
$form.Controls.Add($label)
$form.Controls.Add($listBox)
$form.Controls.Add($statusBar)
$form.Controls.Add($chklabel)
$form.Controls.Add($textBox)
$form.Controls.Add($md5checkbox)
$form.Controls.Add($sha1checkbox)
$form.ResumeLayout()

#MD5 and SHA1 commands
#$md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
#$hash = [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($someFilePath)))

### Write event handlers ###

$button_Click = {
    write-host "Listbox contains:" -ForegroundColor Yellow

	if($checkbox.Checked -eq $True)
    {
        $listBox.Items.Clear()
        $textbox.clear()
         
    }

    if($md5checkbox.Checked -eq $True)
    {
    $textboxtxt = $textbox.text
    $value1 = Compare-Object $textboxtxt $md5string -IncludeEqual | Where-Object {$_.Sideindicator -eq '=='}
    $v1boolean = $value1.Sideindicator -eq '==' 
        #Check for a true match of md5
        If ($v1boolean -eq $True)
        {
        $listbox.Items.Add("We have an MD5 match!")
        $statusBar.Text = ("Match Found")
        #Check for a false match of md5
        }
        If ($v1boolean -eq $False)
        {
        Write-Host "No Match"
        $listbox.Items.Add("No MD5 match")
        $statusBar.Text = ("Match Not Found")
        }    
    }

    
	if($sha1checkbox.Checked -eq $True)
    {
       $textboxtxt = $textbox.text
       $value2 = Compare-Object $textboxtxt $sha1string -IncludeEqual | Where-Object {$_.Sideindicator -eq '=='}
       $v2boolean = $value2.Sideindicator -eq '=='

        If ($v2boolean -eq $True)
        {
        $listbox.Items.Add("We have an SHA1 match!")
        $statusBar.Text = ("Match Found")
        }
        #Check for false match of sha1
        If ($v2boolean -eq $False)
        {
        $listbox.Items.Add("No SHA1 match")
        $statusBar.Text = ("Match Not Found")
        }
         
    }         
}

#Drag over
$listBox_DragOver = [System.Windows.Forms.DragEventHandler]{
	if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) # $_ = [System.Windows.Forms.DragEventArgs]
	{
	    $_.Effect = 'Copy'
        
	}
	else
	{
	    $_.Effect = 'None'
	}
}

#MD5 and SHA1 commands
$md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider	
$listBox_DragDrop = [System.Windows.Forms.DragEventHandler]{
	foreach ($filename in $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)) # $_ = [System.Windows.Forms.DragEventArgs]
    {
		$listBox.Items.Add($filename)
        $md5hash = [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($filename)))
        $listBox.Items.Add("MD5: $md5hash")
        $sha1hash = Get-FileHash $filename -Algorithm SHA1 | select-object -ExpandProperty Hash
        $listbox.Items.Add("SHA1: $sha1hash")
        $global:md5string = $md5hash.tostring()
        $global:sha1string = $sha1hash.tostring()
        Write-Host "MD5: $md5string"
        Write-Host "SHA1: $sha1string"
	}
    $statusBar.Text = ("Checksums calculated")
}

$form_FormClosed = {
	try
    {
        $listBox.remove_Click($button_Click)
		$listBox.remove_DragOver($listBox_DragOver)
		$listBox.remove_DragDrop($listBox_DragDrop)
        $listBox.remove_DragDrop($listBox_DragDrop)
		$form.remove_FormClosed($Form_Cleanup_FormClosed)
	}
	catch [Exception]
    { }
}


### Wire up events ###

$button.Add_Click($button_Click)
$listBox.Add_DragOver($listBox_DragOver)
$listBox.Add_DragDrop($listBox_DragDrop)
$form.Add_FormClosed($form_FormClosed)

#set icon for form using Base64
$base64IconString = "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
"

#Set Icon Image
$iconimageBytes = [Convert]::FromBase64String($base64IconString)
$ims = New-Object IO.MemoryStream($iconimageBytes, 0, $iconimageBytes.Length)
$ims.Write($iconimageBytes, 0, $iconimageBytes.Length);
$icon = [System.Drawing.Image]::FromStream($ims, $true)
$Form.Icon = [System.Drawing.Icon]::FromHandle((new-object System.Drawing.Bitmap -argument $ims).GetHIcon())

#### Show the form ###

$form.ShowDialog()

