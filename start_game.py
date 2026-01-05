#!/usr/bin/env python3
"""
算24点游戏启动脚本

使用方法：
1. python start_game.py
2. 在浏览器中访问 http://localhost:8000/24-points-game.html
"""

import http.server
import socketserver
import webbrowser
import os
from pathlib import Path

PORT = 8000

def main():
    # 获取当前目录
    current_dir = Path(__file__).parent

    # 切换到demo目录
    os.chdir(current_dir)

    # 创建HTTP服务器
    handler = http.server.SimpleHTTPRequestHandler

    print("🚀 启动算24点游戏服务器...")
    print(f"📁 服务目录: {current_dir}")
    print(f"🌐 访问地址: http://localhost:{PORT}/24-points-game.html")
    print("❌ 按 Ctrl+C 停止服务器")
    print("-" * 50)

    try:
        with socketserver.TCPServer(("", PORT), handler) as httpd:
            print("✅ 服务器启动成功！")
            print("🎮 在浏览器中打开游戏页面开始玩耍吧！")

            # 自动打开浏览器
            try:
                webbrowser.open(f"http://localhost:{PORT}/24-points-game.html")
            except:
                print("💡 请手动在浏览器中访问上述地址")

            # 启动服务器
            httpd.serve_forever()

    except KeyboardInterrupt:
        print("\n👋 服务器已停止")
    except OSError as e:
        if e.errno == 48:  # Address already in use
            print(f"❌ 端口 {PORT} 已被占用，请尝试关闭其他程序或修改端口")
        else:
            print(f"❌ 启动失败: {e}")

if __name__ == "__main__":
    main()
