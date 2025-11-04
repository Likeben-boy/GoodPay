<template>
  <div class="order-detail">
    <!-- 顶部导航 -->
    <van-nav-bar title="订单详情" left-arrow @click-left="goBack" />

    <!-- 订单状态 -->
    <div class="order-status-section">
      <div class="status-icon">
        <van-icon :name="getStatusIcon(order.status)" size="48" :color="getStatusColor(order.status)" />
      </div>
      <h3>{{ getStatusText(order.status) }}</h3>
      <p v-if="order.status === 'processing'">预计 {{ order.estimatedDeliveryTime }} 送达</p>
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
      <img :src="order.restaurantImage" :alt="order.restaurantName" class="restaurant-image" />
      <div class="restaurant-details">
        <h4>{{ order.restaurantName }}</h4>
        <p>订单号：{{ order.orderNumber }}</p>
      </div>
    </div>

    <!-- 订单商品 -->
    <div class="order-items">
      <h4>订单商品</h4>
      <div v-for="item in order.items" :key="item.id" class="order-item">
        <img :src="item.image" :alt="item.name" class="item-image" />
        <div class="item-info">
          <span class="item-name">{{ item.name }}</span>
          <div class="item-price-quantity">
            <span class="item-price">¥{{ item.price }}</span>
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
        <span>{{ order.paymentMethod }}</span>
      </div>
      <div class="info-item">
        <span>配送费</span>
        <span>¥{{ order.deliveryFee }}</span>
      </div>
      <div class="info-item">
        <span>优惠金额</span>
        <span class="discount">-¥{{ order.discount }}</span>
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
      <div class="summary-item">
        <span>优惠</span>
        <span class="discount">-¥{{ order.discount }}</span>
      </div>
      <div class="summary-total">
        <span>实付金额</span>
        <span class="total-amount">¥{{ order.total }}</span>
      </div>
    </div>

    <!-- 底部操作 -->
    <div class="bottom-actions">
      <van-button
        v-if="order.status === 'pending'"
        type="primary"
        block
        @click="goToPayment"
      >
        去支付
      </van-button>
      <van-button
        v-if="order.status === 'processing'"
        type="default"
        block
        @click="contactRestaurant"
      >
        联系商家
      </van-button>
      <van-button
        v-if="order.status === 'completed'"
        type="primary"
        block
        @click="rateOrder"
      >
        评价订单
      </van-button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'

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
    pending: 'clock-o',
    processing: 'logistics',
    completed: 'success'
  }
  return iconMap[status] || 'orders-o'
}

// 获取状态颜色
const getStatusColor = (status) => {
  const colorMap = {
    pending: '#ff976a',
    processing: '#1989fa',
    completed: '#07c160'
  }
  return colorMap[status] || '#969799'
}

// 获取状态文本
const getStatusText = (status) => {
  const statusMap = {
    pending: '等待支付',
    processing: '配送中',
    completed: '已完成'
  }
  return statusMap[status] || status
}

// 格式化时间
const formatTime = (time) => {
  const date = new Date(time)
  return `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日 ${date.getHours()}:${date.getMinutes().toString().padStart(2, '0')}`
}

// 返回
const goBack = () => {
  router.back()
}

// 跳转到支付页面
const goToPayment = () => {
  router.push(`/payment/${order.value.id}`)
}

// 联系商家
const contactRestaurant = () => {
  showToast('功能开发中...')
}

// 评价订单
const rateOrder = () => {
  showToast('功能开发中...')
}

onMounted(() => {
  // TODO: 根据订单ID加载订单详情
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
  display: flex;
  align-items: center;
  gap: 12px;
  background: #ffffff;
  padding: 16px;
  margin-bottom: 12px;
}

.restaurant-image {
  width: 50px;
  height: 50px;
  border-radius: 8px;
  object-fit: cover;
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