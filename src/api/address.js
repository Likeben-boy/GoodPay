import { request } from '@/utils/request'

export const addressApi = {
  // 地址列表
  addressList: (data) => request.get('/users/addresses', data),

  // 新增地址
  addAddress: (data) => request.post('/users/addresses', data),

  // 更新地址
  updateAddress: (addressId, data) => request.put(`/users/addresses/${addressId}`, data),

  // 删除地址
  deleteAddress: (addressId) => request.delete(`/users/addresses/${addressId}`),

  //获取用户默认地址
  getDefaultAddress: () => request.get('/users/addresses/default'),
}