#!/bin/bash

# 算24点游戏 - GitHub Pages 自动部署脚本
# 使用方法：
# 1. 修改下面的配置信息
# 2. 运行: chmod +x deploy-github.sh && ./deploy-github.sh

# ============ 配置信息 (请修改) ============
GITHUB_USERNAME="YOUR_GITHUB_USERNAME"  # 替换为你的GitHub用户名
REPO_NAME="24-points-game"               # 仓库名称
BRANCH="main"                           # 分支名称
COMMIT_MESSAGE="Deploy 24 points game to GitHub Pages"

# GitHub仓库地址
REPO_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"

# ============ 脚本开始 ============
set -e  # 遇到错误立即退出

echo "🚀 开始部署算24点游戏到GitHub Pages"
echo "仓库: ${REPO_URL}"
echo "分支: ${BRANCH}"
echo "----------------------------------------"

# 检查Git是否安装
if ! command -v git &> /dev/null; then
    echo "❌ Git未安装，请先安装Git"
    exit 1
fi

# 检查是否在项目根目录
if [ ! -f "24-points-game.html" ]; then
    echo "❌ 请在demo目录下运行此脚本"
    echo "当前目录: $(pwd)"
    exit 1
fi

# 检查配置是否已修改
if [[ "${GITHUB_USERNAME}" == "YOUR_GITHUB_USERNAME" ]]; then
    echo "❌ 请先修改脚本开头的配置信息"
    echo "需要设置: GITHUB_USERNAME"
    exit 1
fi

# 初始化Git仓库（如果还没有）
if [ ! -d ".git" ]; then
    echo "📝 初始化Git仓库..."
    git init
    git checkout -b ${BRANCH}
fi

# 检查远程仓库
if ! git remote get-url origin &> /dev/null; then
    echo "🔗 添加远程仓库..."
    git remote add origin ${REPO_URL}
else
    echo "🔄 更新远程仓库地址..."
    git remote set-url origin ${REPO_URL}
fi

# 确保在正确的分支
current_branch=$(git branch --show-current)
if [[ "${current_branch}" != "${BRANCH}" ]]; then
    echo "🔀 切换到 ${BRANCH} 分支..."
    git checkout ${BRANCH} 2>/dev/null || git checkout -b ${BRANCH}
fi

# 添加所有文件
echo "📦 添加文件到Git..."
git add .

# 检查是否有更改
if git diff --cached --quiet; then
    echo "ℹ️  没有文件更改，跳过提交"
else
    # 提交更改
    echo "💾 提交更改..."
    git commit -m "${COMMIT_MESSAGE}" || {
        echo "⚠️  没有新更改或提交失败，继续推送..."
    }
fi

# 推送代码
echo "📤 推送代码到GitHub..."
git push -u origin ${BRANCH}

# 检查推送结果
if [ $? -eq 0 ]; then
    echo "✅ 代码推送成功！"
    echo ""
    echo "🌐 访问地址:"
    echo "https://${GITHUB_USERNAME}.github.io/${REPO_NAME}/"
    echo ""
    echo "📋 接下来的步骤:"
    echo "1. 访问GitHub仓库: ${REPO_URL}"
    echo "2. 进入 Settings → Pages"
    echo "3. Source选择 '${BRANCH}' 分支的 '/ (root)' 文件夹"
    echo "4. 保存设置，等待几分钟生效"
    echo ""
    echo "🎉 部署完成！快去分享给朋友们吧！"
else
    echo "❌ 推送失败，请检查："
    echo "1. GitHub用户名是否正确"
    echo "2. 仓库是否存在"
    echo "3. 是否有推送权限"
    echo "4. 网络连接是否正常"
    exit 1
fi
