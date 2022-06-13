#Ergebnisarray erstellen
$finished = New-Object System.Collections.ArrayList
$finished.IsFixedSize

#Nach URL-Liste fragen
Write-Host "Geben Sie den Pfad zur URL-Datei ein (Falls diese nicht existiert erstellen Sie bitte eine)"
Write-Host "Beachten Sie dabei bitte folgendes Format: C:\Daten\bsp.txt"
$urlList = Read-Host

#URL-Liste festlegen
$content = Get-Content -Path $urlList


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Erreichbarkeit von jeder URL prüfen
foreach($url in $content){

#Datum in Varibale festlegen
$date = Get-Date

#Statuscode prüfen und Ergebnis in Ergbenisarray speichern
try{
$finished.Add($url + "   ||    Statuscode:  " + (Invoke-WebRequest -uri $url).StatusCode + " (Available)   ||   Checked on:    " + $date)
}

#Falls Website keinen Statuscode zurückgibt ist sie nicht erreichbar
catch
{
$finished.Add($url + "   ||    Statuscode: 404 (Not available)  ||   Checked on:    " + $date)
}
}

#Fragen ob die URL-Liste erweitert werden soll
Write-Host "Würden Sie die URL-List gerne erweitern? [y/n]"
[string]$eingabe = Read-Host

#Falls ja eigegebene URL in der URL-Datei speichern
if($eingabe -eq "y")
{
Write-Host "Geben Sie eine URL ein:"
[string]$eingabe2 = Read-Host
Add-Content -Path $urlList -Value `r`n$eingabe2 -PassThru

#Statuscode prüfen und Ergebnis in Ergbenisarray speichern
try{
$finished.Add($eingabe2 + "   ||    Statuscode:  " + (Invoke-WebRequest -uri $eingabe2).StatusCode + "   ||   Checked on:    " + $date)
}

#Falls Website keinen Statuscode zurückgibt ist sie nicht erreichbar
catch
{
$finished.Add($eingabe2 + "   ||    Statuscode:  Not available    ||   Checked on:    " + $date)
}
}

#Fragen ob die Ergebnisse in einer Datei gespeichert werden soll
Write-Host "Möchten Sie die Ergebnisse in einer Text-Datei speichern? [y/n]"
[string]$txtEingabe = Read-Host

#Falls ja Ergebnisse in einer Textdatei speichern
if($txtEingabe -eq "y")
{
#Dateispeicherort festlegen
Write-Host "Wo wollen Sie die Datei Speichern? (Bsp. Dateipfad: C:\Daten\)"
$txtEingabe2 = Read-Host

Write-Host "Geben Sie einen Dateinamen ein (Am Ende des Namen noch ein .txt): "
$fileName = Read-Host

#Neue Datei erstellen
New-Item -Path $txtEingabe2 -Name $fileName -ItemType File
$ErgebnisPath = $txtEingabe2 + $fileName

Add-Content -Path $ErgebnisPath -Value $finished -PassThru

Write-Host -ForegroundColor Green("Ihre Ergebnisse wurden hier gespeichert: " + $txtEingabe2 + "Ergebnisse.txt")
}


#Anzahl URL's in Array zählen
$count = ($finished).Count

#Ergbenistabelle erstellen
$finished | Out-Gridview -Title "WebsiteChecker | Datenmenge - Total: $count"
$content | clip