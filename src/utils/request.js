import { showToast, showFailToast } from 'vant'
import config from '@/config'

const BASE_URL = config.api.baseURL
const TIME_OUT = config.api.timeout

// 判断是否为开发环境
const isDevelopment = config.features.debug;
const shouldLog = config.features.logRequests;

//日志工具
const logger = {
  request: (url,method,data,params) =>{
    if(isDevelopment && shouldLog){
      console.group(`🚀 API 请求: ${method.toUpperCase()} ${url}`)
            console.log('📤 Data:', data)
      console.log('🔍 Params:', params)
      console.log('⏰ Time:', new Date().toLocaleTimeString())
      console.groupEnd()
    }
  },

  response: (url,response,duration) =>{
    if(isDevelopment && shouldLog){
            console.group(`✅ API Response: ${url}`)
      console.log('📥 Response:', response)
      console.log('⏱️ Duration:', `${duration}ms`)
      console.log('⏰ Time:', new Date().toLocaleTimeString())
      console.groupEnd()
  }},
    error: (url, error, duration) => {
    if (isDevelopment) {
      console.group(`❌ API Error: ${url}`)
      console.error('💥 Error:', error)
      console.log('⏱️ Duration:', `${duration}ms`)
      console.log('⏰ Time:', new Date().toLocaleTimeString())
      console.groupEnd()
    }
  }
}

class HttpRequest {
  constructor() {
    this.baseURL = BASE_URL
    this.timeout = TIME_OUT
  }

  request(options) {
    const { url, method = 'GET', data, params, headers = {} } = options
    const startTime = Date.now() // 记录开始时间

    // 获取token
    const token = localStorage.getItem('token')
    if (token) {
      headers['Authorization'] = `Bearer ${token}`
    }

    // 构建完整URL
    const fullUrl = `${this.baseURL}${url}${params ? '?' + new URLSearchParams(params) : ''}`
    logger.request(url, method, data, params)
    const config = {
      method,
      headers: {
        'Content-Type': 'application/json',
        ...headers
      },
      timeout: this.timeout
    }

    if (method.toUpperCase() !== 'GET' && data) {
      config.body = JSON.stringify(data)
    }

    return new Promise((resolve, reject) => {
      const timeoutId = setTimeout(() => {
        const duration = Date.now() - startTime // 实际等待时间
        const timeoutError = new Error('请求超时');
        logger.error(url, timeoutError, duration)
        reject(timeoutError)
      }, this.timeout)

      fetch(fullUrl, config)
        .then(async (response) => {
          clearTimeout(timeoutId)
          const duration = Date.now() - startTime

          if (!response.ok) {
            const errorData = await response.json().catch(() => ({}))
            const error = new Error(errorData.message || `HTTP ${response.status}`)
            logger.error(url, error, duration)
            throw error
          }

          const data = await response.json()

          // 处理业务逻辑错误
          if (data.code !== 200 && data.success !== true) {
            const error = new Error(data.message || '请求失败')
            logger.error(url, error, duration)
            throw error
          }

          logger.response(url, data, duration)
          resolve(data)
        })
        .catch((error) => {
          clearTimeout(timeoutId)
          const duration = Date.now() - startTime

          // 记录错误日志（避免重复记录超时错误）
          if (!error.message.includes('请求超时')) {
            logger.error(url, error, duration)
          }

          // 统一错误处理
          if (error.message.includes('token') || error.message.includes('认证')) {
            showToast('登录已过期，请重新登录')
            localStorage.removeItem('token')
            localStorage.removeItem('userInfo')
            window.location.href = '/login'
          } else {
            showFailToast(error.message || '网络错误')
          }

          reject(error)
        })
    })
  }

  get(url, params, config = {}) {
    return this.request({ url, method: 'GET', params, ...config })
  }

  post(url, data, config = {}) {
    return this.request({ url, method: 'POST', data, ...config })
  }

  put(url, data, config = {}) {
    return this.request({ url, method: 'PUT', data, ...config })
  }

  delete(url, config = {}) {
    return this.request({ url, method: 'DELETE', ...config })
  }
}

export const request = new HttpRequest()