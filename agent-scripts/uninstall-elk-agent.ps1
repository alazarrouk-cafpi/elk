& sc.exe stop 'Elastic Agent'
& sc.exe delete 'Elastic Agent'
Set-Location -Path "C:\"
Remove-Item -Path "C:\Program Files\Elastic" -Force -Recurse
Remove-Item -Path "C:\Elastic\elastic-agent-8.14.2-windows-x86_64" -Force -Recurse
Remove-Item -Path "C:\Sysmon" -Force -Recurse