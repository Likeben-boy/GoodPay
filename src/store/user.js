import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useUserStore = defineStore('user', () => {
  const token = ref(localStorage.getItem('token') || '')
  const userInfo = ref(JSON.parse(localStorage.getItem('userInfo') || '{}'))
  const isLoggedIn = computed(() => !!token.value)

  // 保存用户数据
  const saveUser = async (userResponse) => {
        token.value = userResponse.token
        userInfo.value = userResponse.user
        localStorage.setItem('token', userResponse.token)
        localStorage.setItem('userInfo', JSON.stringify(userResponse.user))
  }

  // 登出
  const deleteUser = () => {
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
    saveUser,
    deleteUser,
    updateUserInfo
  }
})