# release.ps1 - 版本号更新 + 构建一体化脚本
# 用法:
#   ./release.ps1          先交互式更新版本号，再构建
#   ./release.ps1 -Bump    只更新版本号
#   ./release.ps1 -Build   只构建（跳过版本号更新）

param(
    [switch]$Bump,
    [switch]$Build
)

$packageJson = "package.json"
$tauriConf   = "src-tauri/tauri.conf.json"
$cargoToml   = "src-tauri/Cargo.toml"
$bundlePath  = "src-tauri/target/release/bundle"

function Write-Utf8File {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Content
    )

    $resolvedPath = (Resolve-Path $Path).Path
    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($resolvedPath, $Content, $utf8NoBom)
}

function Invoke-BumpVersion {
    $pkg = Get-Content $packageJson -Raw -Encoding UTF8 | ConvertFrom-Json
    $current = $pkg.version
    $newVersion = Read-Host "请输入新版本号 (x.y.z，回车跳过)"

    if ([string]::IsNullOrWhiteSpace($newVersion)) {
        Write-Host "跳过版本号更新。" -ForegroundColor Gray
        return $false
    }

    if ($newVersion -notmatch '^\d+\.\d+\.\d+$') {
        Write-Host "版本号必须是 x.y.z 格式" -ForegroundColor Red
        exit 1
    }

    if ($newVersion -eq $current) {
        Write-Host "版本号未变化，跳过更新。" -ForegroundColor Gray
        return $false
    }

    $pkg.version = $newVersion
    $pkgContent = ($pkg | ConvertTo-Json -Depth 100) + "`n"
    Write-Utf8File -Path $packageJson -Content $pkgContent

    $tauriConfig = Get-Content $tauriConf -Raw -Encoding UTF8 | ConvertFrom-Json
    $tauriConfig.version = $newVersion
    $tauriContent = ($tauriConfig | ConvertTo-Json -Depth 100) + "`n"
    Write-Utf8File -Path $tauriConf -Content $tauriContent

    $cargoLines = Get-Content $cargoToml -Encoding UTF8
    $inPackageSection = $false
    $versionUpdated = $false
    for ($i = 0; $i -lt $cargoLines.Count; $i++) {
        $line = $cargoLines[$i]
        if ($line -match '^\s*\[package\]\s*$') {
            $inPackageSection = $true
            continue
        }
        if ($inPackageSection -and $line -match '^\s*\[[^\]]+\]\s*$') {
            $inPackageSection = $false
        }
        if ($inPackageSection -and -not $versionUpdated -and $line -match '^\s*version\s*=\s*"[^"]*"\s*$') {
            $cargoLines[$i] = "version = `"$newVersion`""
            $versionUpdated = $true
        }
    }
    if (-not $versionUpdated) {
        Write-Host "未找到 [package] 下的 version 字段，无法更新 Cargo.toml" -ForegroundColor Red
        exit 1
    }
    $cargoContent = ($cargoLines -join "`n") + "`n"
    Write-Utf8File -Path $cargoToml -Content $cargoContent

    Write-Host "版本号已更新为 $newVersion" -ForegroundColor Green
    return $true
}

function Invoke-Build {
    npm run tauri:build
    if ($LASTEXITCODE -ne 0) {
        Write-Host "构建失败！" -ForegroundColor Red
        exit 1
    }
    Write-Host "构建完成，产物目录: $bundlePath" -ForegroundColor Green
}

if ($Bump -and -not $Build) {
    Invoke-BumpVersion | Out-Null
} elseif ($Build -and -not $Bump) {
    Invoke-Build
} else {
    Invoke-BumpVersion | Out-Null
    Invoke-Build
}
