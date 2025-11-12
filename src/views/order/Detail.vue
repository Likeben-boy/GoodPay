<template>
  <div class="order-detail">
    <!-- 顶部导航 -->
    <van-nav-bar title="订单详情" left-arrow @click-left="goBack" />

    <!-- 订单状态 -->
    <div class="order-status-section">
      <div class="status-icon">
        <van-icon :name="getStatusIcon(order.orderStatus)" size="48" :color="getStatusColor(order.orderStatus)" />
      </div>
      <h3>{{ getStatusText(order.orderStatus) }}</h3>
      <p v-if="order.orderStatus === 'delivering'">预计 {{ formatEstimatedTime(order.estimatedDeliveryTime) }} 送达</p>
    </div>

    <!-- 配送信息 -->
    <div class="delivery-info">
      <div class="delivery-address">
        <div class="address-header">
          <van-icon name="location-o" />
          <span>配送地址</span>
        </div>
        <div class="address-content">
          <p class="contact-info">{{ order.contactName }} {{ order.contactPhone }}</p>
          <p class="address-text">{{ order.deliveryAddress }}</p>
        </div>
      </div>
    </div>

    <!-- 餐厅信息 -->
    <div class="restaurant-info">
      <div class="restaurant-details">
        <h4>{{ order.restaurantName }}</h4>
        <p>订单号：{{ order.orderNumber }}</p>
      </div>
    </div>

    <!-- 订单商品 -->
    <div class="order-items">
      <h4>订单商品</h4>
      <div v-for="item in order.orderItems" :key="item.id" class="order-item">
        <img :src="item.dishImage" :alt="item.dishName" class="item-image" />
        <div class="item-info">
          <span class="item-name">{{ item.dishName }}</span>
          <div class="item-price-quantity">
            <span class="item-price">¥{{ item.dishPrice }}</span>
            <span class="item-quantity">x{{ item.quantity }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 订单信息 -->
    <div class="order-info">
      <div class="info-item">
        <span>下单时间</span>
        <span>{{ formatTime(order.createdAt) }}</span>
      </div>
      <div class="info-item">
        <span>支付方式</span>
        <span>{{ getPaymentMethodText(order.paymentMethod) }}</span>
      </div>
      <div class="info-item">
        <span>配送费</span>
        <span>¥{{ order.deliveryFee }}</span>
      </div>
      <div v-if="order.discountAmount && order.discountAmount > 0" class="info-item">
        <span>优惠金额</span>
        <span class="discount">-¥{{ order.discountAmount }}</span>
      </div>
    </div>

    <!-- 订单金额 -->
    <div class="order-summary">
      <div class="summary-item">
        <span>商品金额</span>
        <span>¥{{ order.subtotal }}</span>
      </div>
      <div class="summary-item">
        <span>配送费</span>
        <span>¥{{ order.deliveryFee }}</span>
      </div>
      <div v-if="order.discountAmount && order.discountAmount > 0" class="summary-item">
        <span>优惠</span>
        <span class="discount">-¥{{ order.discountAmount }}</span>
      </div>
      <div class="summary-total">
        <span>实付金额</span>
        <span class="total-amount">¥{{ order.totalAmount }}</span>
      </div>
    </div>

    <!-- 底部操作 -->
    <div class="bottom-actions">
      <van-button
        v-if="order.orderStatus === 'created'"
        type="primary"
        block
        @click="goToPayment"
      >
        去支付
      </van-button>
      <van-button
        v-if="order.orderStatus === 'confirmed' || order.orderStatus === 'preparing' || order.orderStatus === 'cancelled'"
        type="default"
        block
        @click="contactRestaurant"
      >
        联系商家
      </van-button>
      <van-button
        v-if="order.orderStatus === 'delivering'"
        type="primary"
        block
        @click="confirmReceipt"
      >
        确认收货
      </van-button>
      <van-button
        v-if="order.orderStatus === 'completed'"
        type="default"
        block
        @click="requestRefund"
      >
        申请退款
      </van-button>
      <!-- cancelled 状态不显示任何按钮 -->
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { orderApi } from '@/api'

const route = useRoute()
const router = useRouter()

// 订单详情
const order = ref({
  id: route.params.id,
  orderNumber: 'GP2024011500123',
  restaurantName: '川味小厨',
  restaurantImage: '/images/restaurant1.jpg',
  status: 'processing',
  contactName: '张三',
  contactPhone: '138****5678',
  deliveryAddress: '北京市朝阳区三里屯街道工体北路8号院1号楼',
  items: [
    {
      id: 1,
      name: '麻婆豆腐',
      image: '/images/dish1.jpg',
      price: 18,
      quantity: 1
    },
    {
      id: 3,
      name: '白米饭',
      image: '/images/rice.jpg',
      price: 2,
      quantity: 2
    }
  ],
  subtotal: 22,
  deliveryFee: 5,
  discount: 2,
  total: 25,
  paymentMethod: '微信支付',
  createdAt: new Date('2024-01-15T12:30:00'),
  estimatedDeliveryTime: '13:00'
})

// 获取状态图标
const getStatusIcon = (status) => {
  const iconMap = {
    created: 'clock-o',         // 已创建 - 等待图标
    confirmed: 'passed',        // 已确认 - 对勾图标
    preparing: 'fire',          // 制作中 - 火焰图标
    delivering: 'logistics',    // 配送中 - 物流图标
    completed: 'success',       // 已完成 - 成功图标
    cancelled: 'cross'          // 已取消 - 叉号图标
  }
  return iconMap[status] || 'orders-o'
}

// 获取状态颜色
const getStatusColor = (status) => {
  const colorMap = {
    created: '#ff976a',      // 橙色 - 等待支付
    confirmed: '#1989fa',    // 蓝色 - 已确认
    preparing: '#ff6b35',    // 深橙色 - 制作中
    delivering: '#07c160',   // 绿色 - 配送中
    completed: '#07c160',    // 绿色 - 已完成
    cancelled: '#ee0a24'     // 红色 - 已取消
  }
  return colorMap[status] || '#969799'
}

// 获取状态文本
const getStatusText = (status) => {
  const statusMap = {
    created: '等待支付',
    confirmed: '订单已确认',
    preparing: '制作中',
    delivering: '配送中',
    completed: '已完成',
    cancelled: '已取消'
  }
  return statusMap[status] || status
}

// 格式化时间
const formatTime = (time) => {
  const date = new Date(time)
  return `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日 ${date.getHours()}:${date.getMinutes().toString().padStart(2, '0')}`
}

// 格式化预计送达时间
const formatEstimatedTime = (time) => {
  if (!time) return ''
  const date = new Date(time)
  return `${date.getHours()}:${date.getMinutes().toString().padStart(2, '0')}`
}

// 获取支付方式文本
const getPaymentMethodText = (method) => {
  const methodMap = {
    'wechat': '微信支付',
    'alipay': '支付宝',
    'balance': '余额支付'
  }
  return methodMap[method] || method
}

// 该页面固定返回订单列表返回
const goBack = () => {
  router.push('/order')
}

// 跳转到支付页面
const goToPayment = () => {
    // 跳转到订单处理中页面
  router.push({
    path: "/order/processing",
    query: {
      orderId: order.value.id,
      orderNumber: order.value.orderNumber,
      paymentMethod: order.value.paymentMethod,
    },
  });
}

// 联系商家
const contactRestaurant = () => {
  showToast('功能开发中...')
}

// 确认收货
const confirmReceipt = async() => {
  showToast('确认收货成功')
  console.log(order);
  
  // 调用api
  await orderApi.confirmOrder(order.value.id);
  loadOrder();
}

// 申请退款
const requestRefund = () => {
  showToast('功能开发中...')
}

const loadOrder = async() =>{
    // 根据订单ID加载订单详情
  try {
    const response = await orderApi.getOrderDetail(Number(route.params.id))
    if (response.status === 'success') {
      order.value = response.data.order
    }
  } catch (error) {
    console.error('获取订单详情失败:', error)
  }
}

onMounted(async () => {
loadOrder()
})
</script>

<style scoped>
.order-detail {
  min-height: 100vh;
  background: #f5f5f5;
  padding-bottom: 80px;
}

.order-status-section {
  background: #ffffff;
  padding: 40px 0;
  text-align: center;
  margin-bottom: 12px;
}

.status-icon {
  margin-bottom: 16px;
}

.order-status-section h3 {
  margin: 0 0 8px 0;
  font-size: 20px;
  font-weight: bold;
}

.order-status-section p {
  margin: 0;
  font-size: 14px;
  color: #969799;
}

.delivery-info {
  background: #ffffff;
  padding: 16px;
  margin-bottom: 12px;
}

.address-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
  font-size: 16px;
  font-weight: 600;
}

.contact-info {
  margin: 0 0 4px 0;
  font-size: 14px;
  font-weight: 600;
}

.address-text {
  margin: 0;
  font-size: 14px;
  color: #333;
  line-height: 1.4;
}

.restaurant-info {
  background: #ffffff;
  padding: 16px;
  margin-bottom: 12px;
}

.restaurant-details h4 {
  margin: 0 0 4px 0;
  font-size: 16px;
  font-weight: 600;
}

.restaurant-details p {
  margin: 0;
  font-size: 12px;
  color: #969799;
}

.order-items {
  background: #ffffff;
  padding: 16px;
  margin-bottom: 12px;
}

.order-items h4 {
  margin: 0 0 16px 0;
  font-size: 16px;
  font-weight: 600;
}

.order-item {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.order-item:last-child {
  margin-bottom: 0;
}

.item-image {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  object-fit: cover;
}

.item-info {
  flex: 1;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.item-name {
  font-size: 14px;
  color: #333;
}

.item-price-quantity {
  text-align: right;
}

.item-price {
  display: block;
  font-size: 14px;
  color: #333;
  margin-bottom: 4px;
}

.item-quantity {
  font-size: 12px;
  color: #969799;
}

.order-info {
  background: #ffffff;
  padding: 16px;
  margin-bottom: 12px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 14px;
}

.info-item:last-child {
  margin-bottom: 0;
}

.discount {
  color: #ff6b6b;
}

.order-summary {
  background: #ffffff;
  padding: 16px;
  margin-bottom: 12px;
}

.summary-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 14px;
}

.summary-item:last-child {
  margin-bottom: 0;
}

.summary-total {
  display: flex;
  justify-content: space-between;
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid #f5f5f5;
  font-size: 16px;
  font-weight: bold;
}

.total-amount {
  color: #ff6b6b;
}

.bottom-actions {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: #ffffff;
  padding: 16px;
  border-top: 1px solid #f5f5f5;
}
</style>