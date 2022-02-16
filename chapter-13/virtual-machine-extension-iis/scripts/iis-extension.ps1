install-windowsfeature -name Web-Server -IncludeManagementTools
Set-Location -Path c:\inetpub\wwwroot
Add-Content iisstart.htm "<!DOCTYPE html><head><meta charset='utf-8'><title>ARM template - Custom extension</title><meta name='author' content='@DaveRndn'></head><body><H1> Your custom extension works</H1></body></html>"
Invoke-command -ScriptBlock{iisreset}