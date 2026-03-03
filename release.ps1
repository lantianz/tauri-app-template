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

function Invoke-BumpVersion {
    $pkg = Get-Content $packageJson -Raw | ConvertFrom-Json
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

    $pkgContent = Get-Content $packageJson -Raw
    $pkgContent = $pkgContent -replace '"version"\s*:\s*"[^"]*"', "`"version`": `"$newVersion`""
    Set-Content $packageJson -Value $pkgContent -NoNewline

    $tauriContent = Get-Content $tauriConf -Raw
    $tauriContent = $tauriContent -replace '"version"\s*:\s*"[^"]*"', "`"version`": `"$newVersion`""
    Set-Content $tauriConf -Value $tauriContent -NoNewline

    $cargoContent = Get-Content $cargoToml -Raw
    $cargoContent = $cargoContent -replace '(?m)^(version\s*=\s*)"[^"]*"', "`${1}`"$newVersion`""
    Set-Content $cargoToml -Value $cargoContent -NoNewline

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
