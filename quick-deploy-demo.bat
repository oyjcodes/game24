@echo off
chcp 65001 >nul
title 算24点游戏 - 快速部署演示

echo.
echo ===========================================
echo     🃏 算24点游戏 - 快速部署演示
echo ===========================================
echo.
echo 这个脚本将演示如何快速部署游戏到网上
echo.
echo 步骤1: 创建GitHub仓库
echo --------------------------------------------
echo 1. 访问: https://github.com/new
echo 2. 仓库名: 24-points-game (或任意名称)
echo 3. 设为公开仓库
echo 4. 点击 "Create repository"
echo.
pause

echo.
echo 步骤2: 配置部署脚本
echo --------------------------------------------
echo 1. 打开 deploy-github.ps1 文件
echo 2. 修改第7行: YOUR_GITHUB_USERNAME 改为你的GitHub用户名
echo 3. 保存文件
echo.
pause

echo.
echo 步骤3: 运行部署脚本
echo --------------------------------------------
echo 现在将运行部署脚本...
echo.
powershell.exe -ExecutionPolicy Bypass -File "%~dp0deploy-github.ps1"

if %errorlevel% equ 0 (
    echo.
    echo ===========================================
    echo         🎉 部署成功！
    echo ===========================================
    echo.
    echo 接下来的步骤:
    echo 1. 访问你的GitHub仓库
    echo 2. 进入 Settings → Pages 标签
    echo 3. Source 选择你的分支和根目录
    echo 4. 保存后等待5-10分钟
    echo.
    echo 你的游戏地址将是:
    echo https://YOUR_USERNAME.github.io/REPO_NAME/
    echo.
    echo 🚀 快去分享给朋友们玩吧！
    echo.
) else (
    echo.
    echo ❌ 部署失败，请检查错误信息
    echo.
)

echo 按任意键退出...
pause >nul
