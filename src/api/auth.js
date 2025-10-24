import { request } from '@/utils/request'

export const authApi = {
  // 用户登录
  login: (data) => request.post('/users/login', data),

  // 用户注册
  register: (data) => request.post('/users/register', data),

  // 发送验证码
  sendCode: (phone) => request.post('/users/send-code', { phone }),

  // 验证码登录
  codeLogin: (data) => request.post('/users/code-login', data),

  // 刷新token
  refreshToken: (refreshToken) => request.post('/users/refresh-token', { refreshToken }),

  // 退出登录
  logout: () => request.post('/users/logout')
}