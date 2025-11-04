import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useUserStore = defineStore('user', () => {
  const token = ref(localStorage.getItem('token') || '')
  const refreshToken = ref(localStorage.getItem('refreshToken') || '')
  const userInfo = ref(JSON.parse(localStorage.getItem('userInfo') || '{}'))
  const isLoggedIn = computed(() => !!token.value)

  // 保存用户数据
  const saveUser = (userResponse) => {
    // 验证传入的参数结构
    if (!userResponse) {
      throw new Error('userResponse不能为空')
    }

    if (!userResponse.tokens) {
      throw new Error('tokens不能为空')
    }

    if (!userResponse.tokens.accessToken) {
      throw new Error('accessToken不能为空')
    }

    if (!userResponse.tokens.refreshToken) {
      throw new Error('refreshToken不能为空')
    }

    if (!userResponse.user) {
      throw new Error('user不能为空')
    }

    token.value = userResponse.tokens.accessToken
    refreshToken.value = userResponse.tokens.refreshToken
    userInfo.value = userResponse.user
    localStorage.setItem('token', token.value)
    localStorage.setItem('refreshToken', refreshToken.value)
    localStorage.setItem('userInfo', JSON.stringify(userInfo.value))
  }

  // 登出
  const deleteUser = () => {
    token.value = ''
    refreshToken.value = ''
    userInfo.value = {}
    localStorage.removeItem('token')
    localStorage.removeItem('refreshToken')
    localStorage.removeItem('userInfo')
  }

  //刷新令牌
  const refreshAccessToken =(accessToken) =>{
    token.value = accessToken;
  }

  // 更新用户信息
  const updateUserInfo = (info) => {
    userInfo.value = { ...userInfo.value, ...info }
    localStorage.setItem('userInfo', JSON.stringify(userInfo.value))
  }

  return {
    token,
    refreshToken,
    userInfo,
    isLoggedIn,
    saveUser,
    deleteUser,
    updateUserInfo,
    refreshAccessToken
  }
})