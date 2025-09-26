import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useUserStore = defineStore('user', () => {
  const token = ref(localStorage.getItem('token') || '')
  const userInfo = ref(JSON.parse(localStorage.getItem('userInfo') || '{}'))
  const isLoggedIn = computed(() => !!token.value)

  // 登录
  const login = async (credentials) => {
    try {
      // TODO: 调用登录API
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(credentials)
      })

      const data = await response.json()
      if (data.success) {
        token.value = data.token
        userInfo.value = data.user
        localStorage.setItem('token', data.token)
        localStorage.setItem('userInfo', JSON.stringify(data.user))
        return { success: true }
      }
      return { success: false, message: data.message }
    } catch (error) {
      return { success: false, message: '登录失败' }
    }
  }

  // 注册
  const register = async (userData) => {
    try {
      // TODO: 调用注册API
      const response = await fetch('/api/auth/register', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(userData)
      })

      const data = await response.json()
      if (data.success) {
        return { success: true }
      }
      return { success: false, message: data.message }
    } catch (error) {
      return { success: false, message: '注册失败' }
    }
  }

  // 登出
  const logout = () => {
    token.value = ''
    userInfo.value = {}
    localStorage.removeItem('token')
    localStorage.removeItem('userInfo')
  }

  // 更新用户信息
  const updateUserInfo = (info) => {
    userInfo.value = { ...userInfo.value, ...info }
    localStorage.setItem('userInfo', JSON.stringify(userInfo.value))
  }

  return {
    token,
    userInfo,
    isLoggedIn,
    login,
    register,
    logout,
    updateUserInfo
  }
})