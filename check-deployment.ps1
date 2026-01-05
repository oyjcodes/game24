# 检查部署状态脚本
param(
    [string]$Username = "YOUR_GITHUB_USERNAME",
    [string]$RepoName = "24-points-game"
)

Write-Host "🔍 检查算24点游戏部署状态" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Yellow

if ($Username -eq "YOUR_GITHUB_USERNAME") {
    Write-Host "❌ 请设置你的GitHub用户名" -ForegroundColor Red
    Write-Host "修改脚本: `$Username = '你的用户名'" -ForegroundColor Yellow
    exit 1
}

$urls = @(
    "https://${Username}.github.io/${RepoName}/",
    "https://${Username}.github.io/${RepoName}/24-points-game.html"
)

Write-Host "🌐 检查访问地址:" -ForegroundColor Green
foreach ($url in $urls) {
    Write-Host "  $url" -ForegroundColor White
}

Write-Host "" -ForegroundColor White
Write-Host "📋 检查步骤:" -ForegroundColor Cyan
Write-Host "1. 确保GitHub仓库已创建" -ForegroundColor White
Write-Host "2. 确保GitHub Pages已启用" -ForegroundColor White
Write-Host "3. 等待5-10分钟部署完成" -ForegroundColor White
Write-Host "4. 如果访问失败，检查GitHub Pages设置" -ForegroundColor White

Write-Host "" -ForegroundColor White
Write-Host "🔗 相关链接:" -ForegroundColor Green
Write-Host "  仓库地址: https://github.com/${Username}/${RepoName}" -ForegroundColor White
Write-Host "  Pages设置: https://github.com/${Username}/${RepoName}/settings/pages" -ForegroundColor White
Write-Host "  部署状态: https://github.com/${Username}/${RepoName}/actions" -ForegroundColor White

Write-Host "" -ForegroundColor White
Write-Host "💡 提示: 如果仍然无法访问，可能是:" -ForegroundColor Yellow
Write-Host "  • 域名解析需要时间(最多24小时)" -ForegroundColor White
Write-Host "  • GitHub Pages正在构建中" -ForegroundColor White
Write-Host "  • 仓库设置为私有(需要公开)" -ForegroundColor White
Write-Host "  • 自定义域名配置问题" -ForegroundColor White

Write-Host "" -ForegroundColor White
Write-Host "🎮 游戏部署完成后，就可以邀请朋友们一起来玩啦！" -ForegroundColor Green
