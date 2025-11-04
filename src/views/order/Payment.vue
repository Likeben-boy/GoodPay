<template>
  <div class="payment">
    <!-- 顶部导航 -->
    <van-nav-bar title="支付订单" left-arrow @click-left="goBack" />

    <!-- 订单信息 -->
    <div class="order-info">
      <div class="restaurant-info">
        <img :src="order.restaurantImage" :alt="order.restaurantName" class="restaurant-image" />
        <div class="restaurant-details">
          <h4>{{ order.restaurantName }}</h4>
          <p>订单号：{{ order.orderNumber }}</p>
        </div>
      </div>
      <div class="order-amount">
        <span>需支付</span>
        <span class="amount">¥{{ order.total }}</span>
      </div>
    </div>

    <!-- 支付方式 -->
    <div class="payment-methods">
      <h4>支付方式</h4>
      <div class="payment-list">
        <div
          v-for="method in paymentMethods"
          :key="method.id"
          :class="['payment-item', { active: selectedPayment === method.id }]"
          @click="selectPayment(method.id)"
        >
          <div class="payment-left">
            <van-icon :name="method.icon" :color="method.color" size="24" />
            <div class="payment-info">
              <span class="payment-name">{{ method.name }}</span>
              <span class="payment-desc">{{ method.description }}</span>
            </div>
          </div>
          <van-icon v-if="selectedPayment === method.id" name="success" color="#07c160" />
        </div>
      </div>
    </div>

    <!-- 优惠券 -->
    <div class="coupon-section">
      <div class="coupon-item" @click="showCouponList">
        <van-icon name="coupon-o" />
        <span>优惠券</span>
        <div class="coupon-right">
          <span v-if="selectedCoupon" class="coupon-selected">{{ selectedCoupon.name }}</span>
          <span v-else class="coupon-hint">暂无可用</span>
          <van-icon name="arrow" />
        </div>
      </div>
    </div>

    <!-- 支付金额明细 -->
    <div class="payment-details">
      <div class="detail-item">
        <span>商品金额</span>
        <span>¥{{ order.subtotal }}</span>
      </div>
      <div class="detail-item">
        <span>配送费</span>
        <span>¥{{ order.deliveryFee }}</span>
      </div>
      <div class="detail-item" v-if="discount > 0">
        <span>优惠</span>
        <span class="discount">-¥{{ discount }}</span>
      </div>
      <div class="detail-total">
        <span>实付金额</span>
        <span class="total-amount">¥{{ finalAmount }}</span>
      </div>
    </div>

    <!-- 支付密码 -->
    <div class="password-section">
      <van-field
        v-model="password"
        type="password"
        label="支付密码"
        placeholder="请输入支付密码"
        maxlength="6"
      />
    </div>

    <!-- 底部支付按钮 -->
    <div class="bottom-actions">
      <van-button
        type="primary"
        block
        :disabled="!selectedPayment || !password"
        :loading="isPaying"
        @click="handlePayment"
      >
        确认支付 ¥{{ finalAmount }}
      </van-button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()
const password = ref('')
const selectedPayment = ref('wechat')
const isPaying = ref(false)

// 订单信息
const order = ref({
  id: route.params.orderId,
  orderNumber: 'GP2024011500123',
  restaurantName: '川味小厨',
  restaurantImage: '/images/restaurant1.jpg',
  subtotal: 22,
  deliveryFee: 5,
  total: 27
})

// 支付方式
const paymentMethods = ref([
  {
    id: 'wechat',
    name: '微信支付',
    description: '推荐使用微信支付',
    icon: 'wechat-pay',
    color: '#07c160'
  },
  {
    id: 'alipay',
    name: '支付宝',
    description: '快速安全支付',
    icon: 'alipay',
    color: '#1677ff'
  },
  {
    id: 'balance',
    name: '余额支付',
    description: '账户余额支付',
    icon: 'balance-pay',
    color: '#ff976a'
  }
])

// 优惠券
const selectedCoupon = ref(null)
const coupons = ref([
  {
    id: 1,
    name: '新用户立减2元',
    discount: 2,
    condition: '满20元可用'
  }
])

// 计算金额
const discount = computed(() => {
  if (selectedCoupon.value && order.value.total >= 20) {
    return selectedCoupon.value.discount
  }
  return 0
})

const finalAmount = computed(() => {
  return order.value.total - discount.value
})

// 选择支付方式
const selectPayment = (methodId) => {
  selectedPayment.value = methodId
}

// 显示优惠券列表
const showCouponList = () => {
  showToast('功能开发中...')
}

// 返回
const goBack = () => {
  router.back()
}

// 处理支付
const handlePayment = () => {
  if (!selectedPayment.value) {
    showToast('请选择支付方式')
    return
  }

  if (!password.value) {
    showToast('请输入支付密码')
    return
  }

  isPaying.value = true

  // 模拟支付过程
  setTimeout(() => {
    isPaying.value = false
    showSuccessToast('支付成功')

    // 跳转到订单详情页
    setTimeout(() => {
      router.push(`/order/${order.value.id}`)
    }, 1500)
  }, 2000)
}

onMounted(() => {
  // TODO: 根据订单ID加载订单信息
})
</script>

<style scoped>
.payment {
  min-height: 100vh;
  background: #f5f5f5;
  padding-bottom: 80px;
}

.order-info {
  background: #ffffff;
  padding: 20px;
  margin-bottom: 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.restaurant-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.restaurant-image {
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

.restaurant-details p {
  margin: 0;
  font-size: 12px;
  color: #969799;
}

.order-amount {
  text-align: right;
}

.order-amount span:first-child {
  font-size: 14px;
  color: #666;
  display: block;
  margin-bottom: 4px;
}

.amount {
  font-size: 24px;
  font-weight: bold;
  color: #ff6b6b;
}

.payment-methods {
  background: #ffffff;
  padding: 16px;
  margin-bottom: 12px;
}

.payment-methods h4 {
  margin: 0 0 16px 0;
  font-size: 16px;
  font-weight: 600;
}

.payment-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.payment-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px;
  border: 1px solid #f5f5f5;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.payment-item.active {
  border-color: #07c160;
  background: #f6ffed;
}

.payment-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.payment-info {
  display: flex;
  flex-direction: column;
}

.payment-name {
  font-size: 16px;
  font-weight: 600;
  margin-bottom: 4px;
}

.payment-desc {
  font-size: 12px;
  color: #969799;
}

.coupon-section {
  background: #ffffff;
  margin-bottom: 12px;
}

.coupon-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  cursor: pointer;
}

.coupon-right {
  margin-left: auto;
  display: flex;
  align-items: center;
  gap: 8px;
}

.coupon-selected {
  color: #ff6b6b;
  font-size: 14px;
}

.coupon-hint {
  color: #969799;
  font-size: 14px;
}

.payment-details {
  background: #ffffff;
  padding: 16px;
  margin-bottom: 12px;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 14px;
}

.detail-item:last-child {
  margin-bottom: 0;
}

.detail-total {
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

.discount {
  color: #ff6b6b;
}

.password-section {
  background: #ffffff;
  margin-bottom: 12px;
  padding: 0 16px;
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