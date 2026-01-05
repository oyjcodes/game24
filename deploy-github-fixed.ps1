# 算24点游戏 - GitHub Pages 自动部署脚本 (PowerShell)
# 使用方法：
# 1. 修改下面的配置信息
# 2. 右键运行此脚本，或在PowerShell中执行: .\deploy-github-fixed.ps1

# ============ 配置信息 (请修改) ============
param(
    [string]$GitHubUsername = "oyjcodes",  # 替换为你的GitHub用户名
    [string]$RepoName = "game24",              # 仓库名称
    [string]$Branch = "main",                          # 分支名称
    [string]$CommitMessage = "Deploy 24 points game to GitHub Pages"
)

# ============ 脚本开始 ============
$ErrorActionPreference = "Stop"

Write-Host "🚀 开始部署算24点游戏到GitHub Pages" -ForegroundColor Green
Write-Host "仓库: https://github.com/${GitHubUsername}/${RepoName}.git" -ForegroundColor Yellow
Write-Host "分支: ${Branch}" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Cyan

# 检查Git是否安装
try {
    $gitVersion = git --version
    Write-Host "✅ Git版本: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git未安装，请先安装Git: https://git-scm.com" -ForegroundColor Red
    exit 1
}

# 检查是否在demo目录
$currentPath = Get-Location
$gameFile = Join-Path $currentPath "24-points-game.html"
if (!(Test-Path $gameFile)) {
    Write-Host "❌ 请在demo目录下运行此脚本" -ForegroundColor Red
    Write-Host "当前目录: $currentPath" -ForegroundColor Yellow
    exit 1
}

# 检查配置是否已修改
if ($GitHubUsername -eq "YOUR_GITHUB_USERNAME") {
    Write-Host "❌ 请先修改脚本开头的配置信息" -ForegroundColor Red
    Write-Host "需要设置: GitHubUsername" -ForegroundColor Yellow
    exit 1
}

# 初始化Git仓库（如果还没有）
if (!(Test-Path ".git")) {
    Write-Host "📝 初始化Git仓库..." -ForegroundColor Blue
    git init
    git checkout -b $Branch
}

# 检查远程仓库
try {
    $remoteUrl = git remote get-url origin 2>$null
    if ($remoteUrl) {
        $expectedUrl = "https://github.com/${GitHubUsername}/${RepoName}.git"
        if ($remoteUrl -ne $expectedUrl) {
            Write-Host "🔄 更新远程仓库地址..." -ForegroundColor Blue
            git remote set-url origin $expectedUrl
        }
    } else {
        Write-Host "🔗 添加远程仓库..." -ForegroundColor Blue
        git remote add origin "https://github.com/${GitHubUsername}/${RepoName}.git"
    }
} catch {
    Write-Host "🔗 添加远程仓库..." -ForegroundColor Blue
    git remote add origin "https://github.com/${GitHubUsername}/${RepoName}.git"
}

# 确保在正确的分支
$currentBranch = git branch --show-current
if ($currentBranch -ne $Branch) {
    Write-Host "🔀 切换到 ${Branch} 分支..." -ForegroundColor Blue
    try {
        git checkout $Branch
    } catch {
        git checkout -b $Branch
    }
}

# 添加所有文件
Write-Host "📦 添加文件到Git..." -ForegroundColor Blue
git add .

# 检查是否有更改
$status = git status --porcelain
if ($status) {
    Write-Host "💾 提交更改..." -ForegroundColor Blue
    try {
        git commit -m $CommitMessage
        Write-Host "✅ 提交成功" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  没有新更改，继续推送..." -ForegroundColor Yellow
    }
} else {
    Write-Host "ℹ️  没有文件更改，跳过提交" -ForegroundColor Yellow
}

# 推送代码
Write-Host "📤 推送代码到GitHub..." -ForegroundColor Blue
try {
    git push -u origin $Branch
    Write-Host "✅ 代码推送成功！" -ForegroundColor Green

    Write-Host "" -ForegroundColor White
    Write-Host "🌐 访问地址:" -ForegroundColor Cyan
    Write-Host "https://${GitHubUsername}.github.io/${RepoName}/" -ForegroundColor White
    Write-Host "" -ForegroundColor White
    Write-Host "📋 接下来的步骤:" -ForegroundColor Cyan
    Write-Host "1. 访问GitHub仓库: https://github.com/${GitHubUsername}/${RepoName}" -ForegroundColor White
    Write-Host "2. 进入 Settings → Pages" -ForegroundColor White
    Write-Host "3. Source选择 '${Branch}' 分支的 '/ (root)' 文件夹" -ForegroundColor White
    Write-Host "4. 保存设置，等待几分钟生效" -ForegroundColor White
    Write-Host "" -ForegroundColor White
    Write-Host "🎉 部署完成！快去分享给朋友们吧！" -ForegroundColor Green
} catch {
    Write-Host "❌ 推送失败，请检查：" -ForegroundColor Red
    Write-Host "1. GitHub用户名是否正确" -ForegroundColor Yellow
    Write-Host "2. 仓库是否存在" -ForegroundColor Yellow
    Write-Host "3. 是否有推送权限" -ForegroundColor Yellow
    Write-Host "4. 网络连接是否正常" -ForegroundColor Yellow
    exit 1
}
