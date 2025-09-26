import { showToast, showFailToast } from 'vant'

const BASE_URL = '/api'

class HttpRequest {
  constructor() {
    this.baseURL = BASE_URL
    this.timeout = 15000
  }

  request(options) {
    const { url, method = 'GET', data, params, headers = {} } = options

    // 获取token
    const token = localStorage.getItem('token')
    if (token) {
      headers['Authorization'] = `Bearer ${token}`
    }

    // 构建完整URL
    const fullUrl = `${this.baseURL}${url}${params ? '?' + new URLSearchParams(params) : ''}`

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
        reject(new Error('请求超时'))
      }, this.timeout)

      fetch(fullUrl, config)
        .then(async (response) => {
          clearTimeout(timeoutId)

          if (!response.ok) {
            const errorData = await response.json().catch(() => ({}))
            throw new Error(errorData.message || `HTTP ${response.status}`)
          }

          const data = await response.json()

          // 处理业务逻辑错误
          if (data.code !== 200 && data.success !== true) {
            throw new Error(data.message || '请求失败')
          }

          resolve(data)
        })
        .catch((error) => {
          clearTimeout(timeoutId)

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