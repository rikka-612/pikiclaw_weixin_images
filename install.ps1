#!/usr/bin/env powershell
<#
.SYNOPSIS
    安装 Pikiclaw 微信图片支持补丁

.DESCRIPTION
    自动应用 patches/ 目录下的所有补丁到 Pikiclaw

.PARAMETER PikiclawPath
    Pikiclaw 的安装路径，默认为 npm 全局安装位置

.EXAMPLE
    .\install.ps1
    
    .\install.ps1 -PikiclawPath "C:\custom\path\pikiclaw"
#>

param(
    [string]$PikiclawPath = "$env:APPDATA\npm\node_modules\pikiclaw"
)

$ErrorActionPreference = "Stop"

# 颜色输出
function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Success($msg) { Write-Host "[SUCCESS] $msg" -ForegroundColor Green }
function Write-Warning($msg) { Write-Host "[WARNING] $msg" -ForegroundColor Yellow }
function Write-Error($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }

Write-Host ""
Write-Host "========================================" -ForegroundColor Blue
Write-Host "  Pikiclaw 微信图片补丁安装工具" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue
Write-Host ""

# 1. 检查 Pikiclaw 路径
Write-Info "检查 Pikiclaw 安装路径..."
if (-not (Test-Path $PikiclawPath)) {
    Write-Error "找不到 Pikiclaw 路径: $PikiclawPath"
    Write-Host "请确认 Pikiclaw 已安装，或指定正确的路径"
    exit 1
}
Write-Success "找到 Pikiclaw: $PikiclawPath"

# 2. 检查补丁文件
Write-Info "检查补丁文件..."
$patchDir = Join-Path $PSScriptRoot "patches"
$patches = @(
    "api.js.patch",
    "channel.js.patch",
    "bot.js.patch"
)

foreach ($patch in $patches) {
    $patchPath = Join-Path $patchDir $patch
    if (-not (Test-Path $patchPath)) {
        Write-Error "找不到补丁文件: $patchPath"
        exit 1
    }
}
Write-Success "所有补丁文件已找到"

# 3. 备份原文件
Write-Info "备份原文件..."
$backupDir = Join-Path $PSScriptRoot "backups"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

$filesToBackup = @(
    "dist/channels/weixin/api.js",
    "dist/channels/weixin/channel.js",
    "dist/channels/weixin/bot.js"
)

foreach ($file in $filesToBackup) {
    $source = Join-Path $PikiclawPath $file
    $dest = Join-Path $backupDir ($file -replace "/", "_")
    
    if (Test-Path $source) {
        Copy-Item -Path $source -Destination $dest -Force
        Write-Success "已备份: $file"
    }
}

Write-Host "备份保存在: $backupDir" -ForegroundColor Gray

# 4. 应用补丁
Write-Info "应用补丁..."

# 检查 git 是否可用（用于应用补丁）
$gitAvailable = $null -ne (Get-Command git -ErrorAction SilentlyContinue)

foreach ($patch in $patches) {
    $patchFile = Join-Path $patchDir $patch
    $targetFile = $patch -replace "\.patch$", ""
    $targetPath = Join-Path $PikiclawPath "dist/channels/weixin/$targetFile"
    
    Write-Info "正在应用: $patch"
    
    if ($gitAvailable) {
        # 使用 git apply
        try {
            Push-Location $PikiclawPath
            git apply $patchFile 2>&1
            Pop-Location
            Write-Success "成功应用: $patch"
        }
        catch {
            Write-Warning "Git apply 失败，尝试手动替换..."
            & $PSScriptRoot\manual-apply.ps1 -PatchFile $patchFile -TargetFile $targetPath
        }
    }
    else {
        Write-Warning "未找到 Git，使用手动替换方式..."
        & $PSScriptRoot\manual-apply.ps1 -PatchFile $patchFile -TargetFile $targetPath
    }
}

# 5. 验证安装
Write-Info "验证安装..."
$apiFile = Join-Path $PikiclawPath "dist/channels/weixin/api.js"
$apiContent = Get-Content $apiFile -Raw

if ($apiContent -contains "downloadAndDecryptWeixinImage") {
    Write-Success "补丁验证通过！"
}
else {
    Write-Warning "无法验证补丁是否正确应用，请检查文件"
}

# 6. 完成提示
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  安装完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "下一步："
Write-Host "  1. 重启 Pikiclaw: pikiclaw restart" -ForegroundColor Yellow
Write-Host "  2. 从微信发送一张图片测试" -ForegroundColor Yellow
Write-Host ""
Write-Host "如需恢复备份：" -ForegroundColor Gray
Write-Host "  Copy-Item '$backupDir\*' '$PikiclawPath\dist\channels\weixin\' -Force" -ForegroundColor Gray
Write-Host ""
