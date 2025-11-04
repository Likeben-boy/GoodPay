import { request } from '@/utils/request'

export const addressApi = {
  // 地址列表
  addressList: (data) => request.get('/users/addresses', data),

  // 新增地址
  addAddress: (data) => request.post('/users/addresses', data),

  // 发送验证码
  sendCode: (phone) => request.post('/users/send-code', { phone }),

  // 验证码登录
  codeLogin: (data) => request.post('/users/code-login', data),

  // 刷新token
  refreshToken: (refreshToken) => request.post('/users/refresh-token', { refreshToken }),

  // 退出登录
  logout: () => request.post('/users/logout')
}