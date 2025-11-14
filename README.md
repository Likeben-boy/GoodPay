# GoodPay - Vue3 外卖系统

<div align="center">

![GoodPay Logo](src/assets/styles/logo.svg)

**一个基于 Vue 3 + Vant 4 的现代化外卖点餐系统**

[![Vue](https://img.shields.io/badge/Vue-3.5.18-4FC08D?style=for-the-badge&logo=vue.js&logoColor=white)](https://vuejs.org/)
[![Vite](https://img.shields.io/badge/Vite-7.0.6-646CFF?style=for-the-badge&logo=vite&logoColor=white)](https://vitejs.dev/)
[![Vant](https://img.shields.io/badge/Vant-4.9.21-F7F8FA?style=for-the-badge&logo=vant&logoColor=1989fa)](https://vantjs.com/)
[![Pinia](https://img.shields.io/badge/Pinia-3.0.3-Yellow?style=for-the-badge&logo=pinia&logoColor=white)](https://pinia.vuejs.org/)

</div>

## 📋 项目概述

GoodPay 是一个功能完整的移动端外卖点餐系统，采用现代化的前端技术栈构建。项目已实现完整的外卖点餐主流程，包括用户认证、餐厅浏览、菜品选择、购物车管理、订单处理和支付等核心功能。

### ✨ 核心特性

- 🏠 **餐厅系统** - 餐厅列表、详情展示、菜品浏览
- 🛒 **购物车功能** - 实时计算、数量管理、菜品选择
- 📦 **订单管理** - 下单流程、订单状态跟踪、历史订单
- 💳 **支付集成** - 多种支付方式、支付状态管理
- 👤 **用户系统** - 登录注册、个人中心、地址管理
- 📱 **移动优化** - 响应式设计、触摸友好、PWA 支持

## 🚀 技术栈

### 前端核心
- **Vue 3.5.18** - 渐进式 JavaScript 框架，使用 Composition API
- **Vite 7.0.6** - 下一代前端构建工具，提供极速的开发体验
- **Vue Router 4.5.1** - Vue.js 官方路由管理器
- **Pinia 3.0.3** - Vue 官方推荐的状态管理库

### UI 框架
- **Vant 4.9.21** - 轻量、可靠的移动端 UI 组件库
- **@vant/area-data 2.1.0** - Vant 省市区数据
- **@vant/auto-import-resolver 1.3.0** - Vant 组件自动导入

### 开发工具
- **unplugin-vue-components 29.1.0** - Vue 组件自动导入
- **unplugin-auto-import 20.2.0** - API 自动导入
- **vite-plugin-vue-devtools 8.0.0** - Vue 开发者工具

## 🏗️ 项目架构

```
GoodPay/
├── public/                     # 静态资源
│   ├── images/                # 图片资源
│   │   ├── banner*.jpg        # 轮播图
│   │   ├── restaurant*.jpg    # 餐厅图片
│   │   └── *.webp/*.jpeg      # 菜品图片
│   └── favicon.ico            # 网站图标
├── src/
│   ├── api/                   # API 接口模块
│   │   ├── auth.js           # 用户认证接口
│   │   ├── restaurant.js     # 餐厅相关接口
│   │   ├── order.js          # 订单相关接口
│   │   └── address.js        # 地址管理接口
│   ├── assets/               # 资源文件
│   │   └── styles/           # 样式文件
│   ├── components/           # 公共组件
│   │   ├── common/          # 通用组件
│   │   └── icons/           # 图标组件
│   ├── router/              # 路由配置
│   ├── store/               # 状态管理
│   │   ├── index.js         # Pinia 实例
│   │   ├── user.js          # 用户状态
│   │   └── cart.js          # 购物车状态
│   ├── utils/               # 工具函数
│   │   ├── index.js         # 通用工具
│   │   ├── request.js       # HTTP 请求封装
│   │   └── error.js         # 错误处理
│   ├── views/               # 页面组件
│   │   ├── home/            # 首页
│   │   ├── restaurant/      # 餐厅相关页面
│   │   ├── order/           # 订单相关页面
│   │   └── user/            # 用户相关页面
│   ├── App.vue              # 根组件
│   └── main.js              # 应用入口
├── database_schema_complete.sql  # 数据库结构
├── vite.config.js           # Vite 配置
├── package.json             # 项目依赖
└── README.md               # 项目文档
```

## 📱 功能模块

### 🏠 首页模块
- 轮播图展示
- 餐厅推荐列表
- 快捷入口导航
- 搜索功能

### 🍽️ 餐厅模块
- **餐厅列表** (`/restaurant/list`)
  - 多种筛选条件（评分、距离、标签）
  - 关键字搜索
  - 分页加载
- **餐厅详情** (`/restaurant/:id`)
  - 餐厅信息展示
  - 菜品分类浏览
  - 菜品详情查看
  - 购物车快速操作

### 🛒 购物车系统
- 实时价格计算
- 菜品数量管理
- 购物车数据持久化
- 批量操作支持

### 📦 订单流程
1. **购物车** (`/cart`) - 查看已选菜品
2. **订单结算** (`/order/checkout`) - 确认订单信息
3. **支付页面** (`/payment/:orderId`) - 选择支付方式
4. **订单处理** (`/order/processing`) - 支付状态跟踪
5. **订单成功** (`/order/success`) - 下单完成确认

### 👤 用户中心
- **登录/注册** (`/login`, `/register`)
- **个人资料** (`/user`)
- **地址管理** (`/user/address`)
  - 地址列表查看
  - 新增/编辑地址
  - 默认地址设置

### 📋 订单管理
- **订单列表** (`/order`) - 历史订单查看
- **订单详情** (`/order/:id`) - 订单信息详情
- 订单状态实时更新

## 🔧 开发环境

### 环境要求
- **Node.js**: ^20.19.0 || >=22.12.0
- **包管理器**: pnpm (推荐)

### 快速开始

1. **克隆项目**
```bash
git clone <repository-url>
cd GoodPay
```

2. **安装依赖**
```bash
pnpm install
```

3. **启动开发服务器**
```bash
pnpm dev
```

4. **构建生产版本**
```bash
pnpm build
```

5. **预览生产构建**
```bash
pnpm preview
```

### 开发配置

项目已配置以下开发特性：

- **路径别名**: `@/` 指向 `src/` 目录
- **组件自动导入**: Vant 组件无需手动导入
- **API 自动导入**: Vue 和 Pinia 的组合式 API 自动导入
- **开发工具**: Vue DevTools 集成
- **热重载**: 开发时支持代码热更新
- **代理配置**: 开发环境 API 代理到 `http://localhost:3000`

## 🔌 API 集成

### 接口模块
项目采用模块化的 API 管理，主要接口模块包括：

- **用户认证** (`src/api/auth.js`)
  - 登录、注册、用户信息获取
- **餐厅管理** (`src/api/restaurant.js`)
  - 餐厅列表、详情、菜品信息
- **订单处理** (`src/api/order.js`)
  - 订单创建、状态查询、历史订单
- **地址管理** (`src/api/address.js`)
  - 地址增删改查、默认地址设置

### 请求配置
- 使用封装的 `request.js` 进行 HTTP 请求
- 统一的错误处理机制
- Token 自动管理和刷新
- 请求/响应拦截器

## 🗄️ 数据库设计

项目包含完整的数据库设计 (`database_schema_complete.sql`)，涵盖：

- **用户系统** - 用户信息、认证管理
- **餐厅系统** - 餐厅信息、菜品管理
- **订单系统** - 订单流程、支付记录
- **地址系统** - 用户地址管理
- **标签系统** - 餐厅分类、标签管理

### 核心表结构
- `users` - 用户表
- `restaurants` - 餐厅表
- `dishes` - 菜品表
- `orders` - 订单表
- `order_items` - 订单详情表
- `user_addresses` - 用户地址表

## 🎨 UI/UX 设计

### 设计特点
- **移动优先**: 专为移动设备优化的界面设计
- **组件化**: 基于 Vant 的统一组件库
- **响应式**: 适配不同屏幕尺寸
- **交互友好**: 流畅的动画和过渡效果
- **主题一致**: 统一的视觉风格和色彩体系

### 关键页面
- 首页轮播和推荐
- 餐厅列表卡片式布局
- 菜品选择浮层交互
- 购物车侧边栏滑出
- 订单状态可视化展示

## 🚀 部署说明

### 生产构建
```bash
pnpm build
```

构建后的文件将生成在 `dist/` 目录中，可直接部署到静态服务器。

### 部署配置
- 项目配置了子路径部署 (`/goodPay/`)
- 支持各种静态托管服务
- 推荐使用 Nginx 进行反向代理

### 环境变量
根据不同环境配置相应的 API 地址和其他环境变量。

## 🤝 贡献指南

### 开发规范
- 使用 `<script setup>` 语法糖
- 遵循 Vue 3 Composition API 最佳实践
- 组件文件使用 PascalCase 命名
- 保持组件单一职责原则

### 提交规范
- 使用清晰的提交信息
- 遵循项目的代码风格
- 确保所有测试通过
- 更新相关文档

## 📄 许可证

本项目采用 MIT 许可证，详情请查看 [LICENSE](LICENSE) 文件。

## 🙏 致谢

感谢以下开源项目和社区：
- [Vue.js](https://vuejs.org/) - 渐进式 JavaScript 框架
- [Vite](https://vitejs.dev/) - 下一代前端构建工具
- [Vant](https://vantjs.com/) - 移动端 UI 组件库
- [Pinia](https://pinia.vuejs.org/) - Vue 状态管理库

---

<div align="center">

**Made with ❤️ by GoodPay Team**

</div>