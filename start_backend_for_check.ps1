$null = New-Item -ItemType Directory -Force -Path C:\dev\design\logs
$cmd = '"D:\IntelliJ IDEA 2023.1.2\apache-maven-3.9.9\bin\mvn.cmd" spring-boot:run > C:\dev\design\logs\backend.log 2>&1'
$p = Start-Process -FilePath cmd.exe -PassThru -WindowStyle Hidden -WorkingDirectory C:\dev\design\drug-traceability -ArgumentList '/c', $cmd
Write-Output "BACKEND_PID=$($p.Id)"
