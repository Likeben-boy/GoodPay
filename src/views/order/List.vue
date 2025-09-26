<template>
  <div class="order-list">
    <!-- 顶部导航 -->
    <van-nav-bar title="我的订单" left-arrow @click-left="goBack" />

    <!-- 订单状态标签 -->
    <van-tabs v-model:active="activeStatus" class="status-tabs">
      <van-tab title="全部" name="all" />
      <van-tab title="待支付" name="pending" />
      <van-tab title="进行中" name="processing" />
      <van-tab title="已完成" name="completed" />
    </van-tabs>

    <!-- 订单列表 -->
    <div class="orders-container">
      <div
        v-for="order in filteredOrders"
        :key="order.id"
        class="order-card"
        @click="goToOrderDetail(order.id)"
      >
        <div class="order-header">
          <div class="restaurant-info">
            <img :src="order.restaurantImage" :alt="order.restaurantName" class="restaurant-logo" />
            <div class="restaurant-details">
              <h4>{{ order.restaurantName }}</h4>
              <span class="order-time">{{ formatTime(order.createdAt) }}</span>
            </div>
          </div>
          <span :class="['order-status', order.status]">{{ getStatusText(order.status) }}</span>
        </div>

        <div class="order-items">
          <div v-for="item in order.items" :key="item.id" class="order-item">
            <img :src="item.image" :alt="item.name" class="item-image" />
            <div class="item-info">
              <span class="item-name">{{ item.name }}</span>
              <span class="item-quantity">x{{ item.quantity }}</span>
            </div>
          </div>
        </div>

        <div class="order-footer">
          <div class="order-total">
            <span>共{{ getTotalItems(order.items) }}件，合计</span>
            <span class="total-price">¥{{ order.total }}</span>
          </div>
          <div class="order-actions">
            <van-button
              v-if="order.status === 'pending'"
              type="primary"
              size="small"
              @click.stop="goToPayment(order.id)"
            >
              去支付
            </van-button>
            <van-button
              v-if="order.status === 'completed'"
              type="default"
              size="small"
              @click.stop="reorder(order)"
            >
              再来一单
            </van-button>
          </div>
        </div>
      </div>

      <!-- 空状态 -->
      <div v-if="filteredOrders.length === 0" class="empty-state">
        <van-icon name="orders-o" size="48" color="#969799" />
        <p>暂无订单</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showToast } from 'vant'

const router = useRouter()
const activeStatus = ref('all')

// 订单数据
const orders = ref([
  {
    id: 1,
    restaurantName: '川味小厨',
    restaurantImage: '/images/restaurant1.jpg',
    status: 'completed',
    total: 45,
    items: [
      {
        id: 1,
        name: '麻婆豆腐',
        image: '/images/dish1.jpg',
        quantity: 1,
        price: 18
      },
      {
        id: 3,
        name: '白米饭',
        image: '/images/rice.jpg',
        quantity: 2,
        price: 2
      }
    ],
    createdAt: new Date('2024-01-15T12:30:00')
  },
  {
    id: 2,
    restaurantName: '粤式茶餐厅',
    restaurantImage: '/images/restaurant2.jpg',
    status: 'processing',
    total: 32,
    items: [
      {
        id: 4,
        name: '烧腊双拼',
        image: '/images/dish4.jpg',
        quantity: 1,
        price: 28
      },
      {
        id: 5,
        name: '奶茶',
        image: '/images/drink1.jpg',
        quantity: 1,
        price: 4
      }
    ],
    createdAt: new Date('2024-01-15T19:45:00')
  },
  {
    id: 3,
    restaurantName: '日式料理',
    restaurantImage: '/images/restaurant3.jpg',
    status: 'pending',
    total: 88,
    items: [
      {
        id: 6,
        name: '寿司拼盘',
        image: '/images/sushi.jpg',
        quantity: 1,
        price: 68
      },
      {
        id: 7,
        name: '味增汤',
        image: '/images/soup.jpg',
        quantity: 2,
        price: 10
      }
    ],
    createdAt: new Date('2024-01-15T20:15:00')
  }
])

// 根据状态筛选订单
const filteredOrders = computed(() => {
  if (activeStatus.value === 'all') {
    return orders.value
  }
  return orders.value.filter(order => order.status === activeStatus.value)
})

// 获取状态文本
const getStatusText = (status) => {
  const statusMap = {
    pending: '待支付',
    processing: '进行中',
    completed: '已完成'
  }
  return statusMap[status] || status
}

// 格式化时间
const formatTime = (time) => {
  const date = new Date(time)
  return `${date.getMonth() + 1}月${date.getDate()}日 ${date.getHours()}:${date.getMinutes().toString().padStart(2, '0')}`
}

// 计算订单总件数
const getTotalItems = (items) => {
  return items.reduce((total, item) => total + item.quantity, 0)
}

// 返回
const goBack = () => {
  router.back()
}

// 跳转到订单详情
const goToOrderDetail = (orderId) => {
  router.push(`/order/${orderId}`)
}

// 跳转到支付页面
const goToPayment = (orderId) => {
  router.push(`/payment/${orderId}`)
}

// 再来一单
const reorder = (order) => {
  showToast('已添加到购物车')
  // TODO: 将订单商品添加到购物车
}

onMounted(() => {
  // TODO: 加载用户订单数据
})
</script>

<style scoped>
.order-list {
  min-height: 100vh;
  background: #f5f5f5;
}

.status-tabs {
  background: #ffffff;
}

.orders-container {
  padding: 12px;
}

.order-card {
  background: #ffffff;
  border-radius: 8px;
  margin-bottom: 12px;
  overflow: hidden;
  cursor: pointer;
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border-bottom: 1px solid #f5f5f5;
}

.restaurant-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.restaurant-logo {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  object-fit: cover;
}

.restaurant-details h4 {
  margin: 0 0 4px 0;
  font-size: 16px;
  font-weight: 600;
}

.order-time {
  font-size: 12px;
  color: #969799;
}

.order-status {
  font-size: 12px;
  padding: 2px 8px;
  border-radius: 12px;
}

.order-status.pending {
  color: #ff976a;
  background: #fff1e6;
}

.order-status.processing {
  color: #1989fa;
  background: #e6f3ff;
}

.order-status.completed {
  color: #07c160;
  background: #e6f7e6;
}

.order-items {
  padding: 16px;
}

.order-item {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 8px;
}

.order-item:last-child {
  margin-bottom: 0;
}

.item-image {
  width: 40px;
  height: 40px;
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

.item-quantity {
  font-size: 12px;
  color: #969799;
}

.order-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border-top: 1px solid #f5f5f5;
}

.order-total {
  font-size: 14px;
  color: #666;
}

.total-price {
  font-size: 16px;
  font-weight: bold;
  color: #ff6b6b;
}

.order-actions {
  display: flex;
  gap: 8px;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 0;
  color: #969799;
}

.empty-state p {
  margin: 16px 0 0 0;
  font-size: 14px;
}
</style>