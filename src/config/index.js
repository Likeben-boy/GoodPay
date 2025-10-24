// 统一配置管理
const config = {
  // API配置
  api: {
    baseURL: import.meta.env.VITE_API_BASE_URL || '/api/v1',
    timeout: 15000,
    retryTimes: 3
  },

  // 应用配置
  app: {
    title: import.meta.env.VITE_APP_TITLE || 'GoodPay',
    version: '1.0.0',
    description: 'Vue3外卖系统'
  },

  // 功能开关
  features: {
    debug: import.meta.env.VITE_DEBUG === 'true',
    logRequests: import.meta.env.VITE_LOG_LEVEL === 'debug'
  },

  // 日志配置
  logging: {
    level: import.meta.env.VITE_LOG_LEVEL || 'info',
    enabled: import.meta.env.DEV
  }
}

export default config