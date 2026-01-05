@echo off
chcp 65001 >nul
title 算24点游戏服务器

echo 🚀 启动算24点游戏服务器...
echo 📁 服务目录: %~dp0
echo 🌐 访问地址: http://localhost:8000/24-points-game.html
echo ❌ 按 Ctrl+C 停止服务器
echo ----------------------------------------

cd /d "%~dp0"
python start_game.py

if errorlevel 1 (
    echo ❌ Python未安装或启动失败
    echo 💡 请确保已安装Python 3.x
    echo 💡 或者直接用浏览器打开 24-points-game.html
    pause
)
