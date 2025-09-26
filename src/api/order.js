import { request } from '@/utils/request'

export const orderApi = {
  // 创建订单
  createOrder: (data) => request.post('/orders', data),

  // 获取订单列表
  getOrderList: (params) => request.get('/orders', params),

  // 获取订单详情
  getOrderDetail: (id) => request.get(`/orders/${id}`),

  // 取消订单
  cancelOrder: (id, reason) => request.post(`/orders/${id}/cancel`, { reason }),

  // 确认收货
  confirmOrder: (id) => request.post(`/orders/${id}/confirm`),

  // 删除订单
  deleteOrder: (id) => request.delete(`/orders/${id}`),

  // 获取订单状态
  getOrderStatus: (id) => request.get(`/orders/${id}/status`),

  // 支付订单
  payOrder: (id, paymentMethod) => request.post(`/orders/${id}/pay`, { paymentMethod }),

  // 查询支付状态
  checkPaymentStatus: (orderId) => request.get(`/orders/${orderId}/payment-status`),

  // 申请退款
  requestRefund: (orderId, data) => request.post(`/orders/${orderId}/refund`, data),

  // 获取退款状态
  getRefundStatus: (orderId) => request.get(`/orders/${orderId}/refund-status`)
}