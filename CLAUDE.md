# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

GoodPay 是一个基于 Vue 3 的外卖系统项目，目前处于初始阶段，使用 Vite 构建工具和 Vant UI 组件库。项目规划包含完整的用户端功能，涵盖用户认证、选择菜品下单、订单处理、支付集成等核心模块。

## 开发环境要求

- Node.js: ^20.19.0 || >=22.12.0
- 包管理器: pnpm

## 常用开发命令

### 项目设置
```bash
pnpm install
```

### 开发模式（热重载）
```bash
pnpm dev
```

### 生产构建
```bash
pnpm build
```

### 构建预览
```bash
pnpm preview
```

## 技术栈

### 前端核心
- **Vue 3**: 主框架，使用 Composition API 和 `<script setup>` 语法
- **Vite**: 构建工具和开发服务器
- **Vant 4**: 移动端 UI 组件库
- **Vue DevTools**: 开发调试工具

### 项目配置
- **路径别名**: `@/` 指向 `src/` 目录
- **JSConfig**: 配置了路径映射，支持 IDE 智能提示

## 项目架构

### 当前结构
项目目前是 Vue 3 标准初始化结构，包含：
- `src/App.vue`: 主应用组件
- `src/main.js`: 应用入口文件
- `src/components/`: 组件目录（当前为示例组件）
- `src/assets/`: 静态资源目录

### 规划架构
根据 README.md 中的项目规划，系统将包含：

#### 前端模块
1. **用户端应用**
   - 首页（餐厅列表）
   - 餐厅详情页
   - 菜品浏览与搜索
   - 购物车功能
   - 订单确认与管理
   - 支付页面

## 开发工作流

### 开发阶段里程碑规划
1. **第一阶段**: 项目基础搭建
2. **第二阶段**: 前端用户界面开发
3. **第三阶段**: 集成后端接口调用
4. **第四阶段**: 支付集成

### 组件开发约定
- 使用 `<script setup>` 语法
- 组件文件使用 PascalCase 命名
- 优先使用 Vant 组件库组件
- 保持组件单一职责原则

### 路径别名使用
- 使用 `@/` 引用 src 目录下的文件
- 例如：`import Component from '@/components/Component.vue'`

## IDE 推荐配置
- **VSCode** + **Volar** 扩展（需要禁用 Vetur）
- 项目包含 `.vscode/` 目录，可能有特定配置

## 注意事项
- 项目使用 pnpm 作为包管理器，避免使用 npm 或 yarn
- 开发时确保 Node.js 版本符合要求
- 当前项目处于初始化阶段，核心功能待开发