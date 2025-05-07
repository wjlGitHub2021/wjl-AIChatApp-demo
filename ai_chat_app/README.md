# AI Chat App

一个基于Flutter开发的AI聊天应用，支持多种AI模型，具有代码高亮显示功能。

## 在线演示

访问 [https://wjlgithub2021.github.io/wjl-AIChatApp-demo/](https://wjlgithub2021.github.io/wjl-AIChatApp-demo/) 体验在线版本。

## 功能特点

- 支持多种AI模型（Google Gemini 2.5 Pro、DeepSeek V3和Shisa AI V2）
- 代码高亮显示，支持多种编程语言
- 支持代码复制和下载
- 深色/浅色主题切换
- 响应式设计，适配不同设备

## 技术栈

- Flutter 3.19.0
- Dart 3.7.2
- Provider 状态管理
- flutter_markdown 代码渲染

## 本地运行

1. 确保已安装Flutter环境
2. 克隆仓库
   ```bash
   git clone https://github.com/wjlGitHub2021/wjl-AIChatApp-demo.git
   cd wjl-AIChatApp-demo
   ```
3. 安装依赖
   ```bash
   flutter pub get
   ```
4. 运行应用
   ```bash
   flutter run -d chrome
   ```

## 部署到GitHub Pages

1. 构建Web应用
   ```bash
   flutter build web --release --base-href /wjl-AIChatApp-demo/
   ```
2. 推送到GitHub
   ```bash
   git add .
   git commit -m "Deploy to GitHub Pages"
   git push origin main
   ```
3. GitHub Actions将自动部署应用到GitHub Pages

## 许可证

MIT
