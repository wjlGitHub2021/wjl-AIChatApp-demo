#!/bin/bash

# 确保脚本在出错时停止执行
set -e

# 构建Flutter Web应用
echo "构建Flutter Web应用..."
flutter build web --release

# 添加所有文件到Git
echo "添加文件到Git..."
git add .

# 提交更改
echo "提交更改..."
git commit -m "Deploy to GitHub Pages"

# 推送到GitHub
echo "推送到GitHub..."
git push origin main

echo "完成！请等待GitHub Actions完成部署。"
echo "部署完成后，您的应用将可以通过以下链接访问："
echo "https://wjlgithub2021.github.io/wjl-AIChatApp-demo/"
