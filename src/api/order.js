import { request } from "@/utils/request";

export const orderApi = {
  // 创建订单
  createOrder: (data) => request.post("/orders/create", data),

  // 获取订单列表
  getOrderList: (params) => request.get("/orders", params),

  // 获取订单详情
  getOrderDetail: (id) => request.get(`/orders/detail`,{orderId:id}),

  // 取消订单
  cancelOrder: (orderId,reason) => request.post(`/orders/cancel`, { orderId,reason }),

  // 确认收货
  confirmOrder: (orderId) => request.post(`/orders/confirm`,{orderId}),

  // 支付订单
  payOrder: (orderId) => request.post(`/orders/pay`, { orderId }),

  // 模拟修改商家接单和配送中状态
  changeStatus: (orderId,status) => request.post(`/orders/changeStatus`, { orderId,status }),

  // 查询支付状态
  checkPaymentStatus: (orderId) =>
    request.get(`/orders/${orderId}/payment-status`),

  // 申请退款
  requestRefund: (orderId,reason) =>
    request.post(`/orders/refund`, {orderId,reason}),

  // 获取退款状态
  getRefundStatus: (orderId) => request.get(`/orders/${orderId}/refund-status`),

  //获取用户首页订单统计
  userTotalOrder:() => request.get('/orders/statistics/overview')
};
