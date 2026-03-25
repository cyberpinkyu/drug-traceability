# 药品全流程追溯监管系统 - 一键启动脚本（后端 + 前端 + App）
# 使用: 在项目根目录执行 .\start.ps1
# 前置: 已安装 Docker、Node.js、Java 8、Maven、Flutter

$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot

Write-Host "=== 药品追溯系统 启动 ===" -ForegroundColor Cyan

# 1. 启动基础设施（MySQL、Redis、RabbitMQ）
Write-Host "`n[1/4] 启动 Docker 基础设施 (MySQL, Redis, RabbitMQ)..." -ForegroundColor Yellow
Set-Location $ProjectRoot
docker-compose up -d mysql redis rabbitmq
if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker 启动失败，请确认已安装并启动 Docker Desktop。" -ForegroundColor Red
    exit 1
}

# 等待 MySQL 就绪
Write-Host "等待 MySQL 就绪 (约 25 秒)..."
Start-Sleep -Seconds 25

# 2. 启动后端（新窗口）
Write-Host "`n[2/4] 启动后端 (Spring Boot)..." -ForegroundColor Yellow
Start-Process powershell `
  -WorkingDirectory "$ProjectRoot\drug-traceability" `
  -ArgumentList "-NoExit", "-Command", "mvn spring-boot:run"

# 等待后端开始监听
Write-Host "等待后端启动 (约 30 秒)..."
Start-Sleep -Seconds 30

# 3. 启动前端（新窗口）
Write-Host "`n[3/4] 启动前端 (Vue + Vite)..." -ForegroundColor Yellow
Start-Process powershell `
  -WorkingDirectory "$ProjectRoot\drug-traceability-frontend" `
  -ArgumentList "-NoExit", "-Command", "npm run dev"

Start-Sleep -Seconds 3

# 4. 启动 Flutter App（新窗口）
Write-Host "`n[4/4] 启动移动端 App (Flutter)..." -ForegroundColor Yellow
$flutterCmd = "flutter run -d windows"
try {
    flutter devices 2>$null | Out-Null
} catch {
    $flutterCmd = "flutter run -d chrome"
}
Start-Process powershell `
  -WorkingDirectory "$ProjectRoot\drug-traceability-app" `
  -ArgumentList "-NoExit", "-Command", $flutterCmd

Write-Host "`n=== 启动完成 ===" -ForegroundColor Green
Write-Host "  后端:     http://localhost:8080"
Write-Host "  前端:     http://localhost:3000"
Write-Host "  App:      见 Flutter 窗口 (Windows/Chrome/真机)"
Write-Host '  关闭:     关闭各窗口即可; 停止 Docker: docker-compose down'
Write-Host ""
