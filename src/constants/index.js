// 订单状态
export const ORDER_STATUS = {
  PENDING: 'pending',           // 待支付
  PAID: 'paid',                 // 已支付
  PREPARING: 'preparing',       // 准备中
  READY: 'ready',               // 待取餐
  DELIVERING: 'delivering',     // 配送中
  COMPLETED: 'completed',       // 已完成
  CANCELLED: 'cancelled',       // 已取消
  REFUNDING: 'refunding',       // 退款中
  REFUNDED: 'refunded'          // 已退款
}

// 订单状态映射
export const ORDER_STATUS_MAP = {
  [ORDER_STATUS.PENDING]: { text: '待支付', color: '#ff6b6b' },
  [ORDER_STATUS.PAID]: { text: '已支付', color: '#4ecdc4' },
  [ORDER_STATUS.PREPARING]: { text: '准备中', color: '#45b7d1' },
  [ORDER_STATUS.READY]: { text: '待取餐', color: '#f9ca24' },
  [ORDER_STATUS.DELIVERING]: { text: '配送中', color: '#6c5ce7' },
  [ORDER_STATUS.COMPLETED]: { text: '已完成', color: '#00b894' },
  [ORDER_STATUS.CANCELLED]: { text: '已取消', color: '#95a5a6' },
  [ORDER_STATUS.REFUNDING]: { text: '退款中', color: '#fd79a8' },
  [ORDER_STATUS.REFUNDED]: { text: '已退款', color: '#a29bfe' }
}

// 支付方式
export const PAYMENT_METHODS = {
  WECHAT: 'wechat',     // 微信支付
  ALIPAY: 'alipay',     // 支付宝
  CASH: 'cash'          // 现金支付
}

// 支付方式映射
export const PAYMENT_METHODS_MAP = {
  [PAYMENT_METHODS.WECHAT]: { text: '微信支付', icon: 'wechat-pay' },
  [PAYMENT_METHODS.ALIPAY]: { text: '支付宝', icon: 'alipay' },
  [PAYMENT_METHODS.CASH]: { text: '现金支付', icon: 'cash-o' }
}

// 餐厅分类
export const RESTAURANT_CATEGORIES = [
  { id: 1, tagName: '中餐', icon: 'fire-o' },
  { id: 2, tagName: '西餐', icon: 'flower-o' },
  { id: 3, tagName: '日料', icon: 'gift-card-o' },
  { id: 4, tagName: '韩料', icon: 'like-o' },
  { id: 5, tagName: '快餐', icon: 'clock-o' },
  { id: 6, tagName: '饮品', icon: 'filter-o' },
  { id: 7, tagName: '甜点', icon: 'birthday-cake-o' },
  { id: 8, tagName: '火锅', icon: 'hot-o' }
]

// 退款原因
export const REFUND_REASONS = [
  { id: 1, text: '不想要了' },
  { id: 2, text: '商品信息有误' },
  { id: 3, text: '配送时间太长' },
  { id: 4, text: '其他原因' }
]

// 本地存储键名
export const STORAGE_KEYS = {
  TOKEN: 'token',
  USER_INFO: 'userInfo',
  CART: 'cart',
  SEARCH_HISTORY: 'searchHistory',
  FAVORITE_RESTAURANTS: 'favoriteRestaurants'
}

// 分页配置
export const PAGINATION = {
  DEFAULT_PAGE_SIZE: 10,
  DEFAULT_PAGE_NUM: 1,
  MAX_PAGE_SIZE: 50
}

// 金额格式化
export const formatPrice = (price) => {
  return `¥${parseFloat(price).toFixed(2)}`
}

// 时间格式化
export const formatTime = (timestamp) => {
  const date = new Date(timestamp)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}