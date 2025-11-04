<template>
  <div class="cart">
    <!-- 顶部导航 -->
    <van-nav-bar title="购物车" left-arrow @click-left="goBack" />

    <!-- 餐厅信息 -->
    <div class="restaurant-info">
      <img :src="restaurant.image" :alt="restaurant.name" class="restaurant-image" />
      <div class="restaurant-details">
        <h4>{{ restaurant.name }}</h4>
        <div class="delivery-info">
          <span>配送费 ¥{{ restaurant.deliveryFee }}</span>
          <span>{{ restaurant.deliveryTime }}分钟</span>
        </div>
      </div>
    </div>

    <!-- 购物车商品 -->
    <div class="cart-items">
      <div v-for="item in cartItems" :key="item.id" class="cart-item">
        <img :src="item.image" :alt="item.name" class="item-image" />
        <div class="item-info">
          <h5>{{ item.name }}</h5>
          <p class="item-description">{{ item.description }}</p>
          <div class="item-actions">
            <span class="item-price">¥{{ item.price }}</span>
            <div class="quantity-controls">
              <van-button
                size="small"
                type="default"
                :disabled="item.quantity <= 1"
                @click="decreaseQuantity(item)"
              >
                -
              </van-button>
              <span class="quantity">{{ item.quantity }}</span>
              <van-button
                size="small"
                type="default"
                @click="increaseQuantity(item)"
              >
                +
              </van-button>
            </div>
          </div>
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

    <!-- 备注 -->
    <div class="remark-section">
      <van-field
        v-model="remark"
        label="备注"
        placeholder="请输入备注信息（选填）"
        type="textarea"
        rows="2"
      />
    </div>

    <!-- 订单金额 -->
    <div class="order-summary">
      <div class="summary-item">
        <span>商品金额</span>
        <span>¥{{ subtotal }}</span>
      </div>
      <div class="summary-item">
        <span>配送费</span>
        <span>¥{{ deliveryFee }}</span>
      </div>
      <div class="summary-item" v-if="discount > 0">
        <span>优惠</span>
        <span class="discount">-¥{{ discount }}</span>
      </div>
      <div class="summary-total">
        <span>合计</span>
        <span class="total-amount">¥{{ total }}</span>
      </div>
    </div>

    <!-- 底部结算 -->
    <div class="checkout-bar">
      <div class="price-info">
        <span>合计</span>
        <span class="total-price">¥{{ total }}</span>
      </div>
      <van-button
        type="primary"
        :disabled="cartItems.length === 0"
        @click="checkout"
      >
        去结算
      </van-button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const remark = ref('')

// 餐厅信息
const restaurant = ref({
  id: 1,
  name: '川味小厨',
  image: '/images/restaurant1.jpg',
  deliveryFee: 5,
  deliveryTime: 30
})

// 购物车商品
const cartItems = ref([
  {
    id: 1,
    name: '麻婆豆腐',
    description: '经典川菜，麻辣鲜香',
    price: 18,
    image: '/images/dish1.jpg',
    quantity: 1
  },
  {
    id: 3,
    name: '白米饭',
    description: '东北优质大米',
    price: 2,
    image: '/images/rice.jpg',
    quantity: 2
  }
])

// 优惠券
const selectedCoupon = ref(null)
const coupons = ref([
  {
    id: 1,
    name: '新用户立减5元',
    discount: 5,
    condition: '满20元可用'
  }
])

// 计算金额
const subtotal = computed(() => {
  return cartItems.value.reduce((total, item) => total + (item.price * item.quantity), 0)
})

const deliveryFee = computed(() => restaurant.value.deliveryFee)

const discount = computed(() => {
  if (selectedCoupon.value && subtotal.value >= 20) {
    return selectedCoupon.value.discount
  }
  return 0
})

const total = computed(() => {
  return subtotal.value + deliveryFee.value - discount.value
})

// 增加商品数量
const increaseQuantity = (item) => {
  item.quantity += 1
}

// 减少商品数量
const decreaseQuantity = (item) => {
  if (item.quantity > 1) {
    item.quantity -= 1
  } else {
    // 删除商品
    const index = cartItems.value.indexOf(item)
    if (index > -1) {
      cartItems.value.splice(index, 1)
    }
  }
}

// 显示优惠券列表
const showCouponList = () => {
  showToast('功能开发中...')
}

// 返回
const goBack = () => {
  router.back()
}

// 结算
const checkout = () => {
  if (cartItems.value.length === 0) {
    showToast('购物车为空')
    return
  }

  // TODO: 创建订单
  router.push('/order')
}

onMounted(() => {
  // TODO: 加载购物车数据
})
</script>

<style scoped>
.cart {
  min-height: 100vh;
  background: #f5f5f5;
  padding-bottom: 80px;
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
  margin: 0 0 8px 0;
  font-size: 16px;
  font-weight: 600;
}

.delivery-info {
  display: flex;
  gap: 16px;
  font-size: 12px;
  color: #969799;
}

.cart-items {
  background: #ffffff;
  padding: 16px;
  margin-bottom: 12px;
}

.cart-item {
  display: flex;
  gap: 12px;
  margin-bottom: 16px;
  padding-bottom: 16px;
  border-bottom: 1px solid #f5f5f5;
}

.cart-item:last-child {
  margin-bottom: 0;
  padding-bottom: 0;
  border-bottom: none;
}

.item-image {
  width: 80px;
  height: 80px;
  border-radius: 8px;
  object-fit: cover;
}

.item-info {
  flex: 1;
}

.item-info h5 {
  margin: 0 0 4px 0;
  font-size: 16px;
  font-weight: 600;
}

.item-description {
  margin: 0 0 8px 0;
  font-size: 12px;
  color: #666;
}

.item-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.item-price {
  font-size: 16px;
  font-weight: bold;
  color: #ff6b6b;
}

.quantity-controls {
  display: flex;
  align-items: center;
  gap: 8px;
}

.quantity {
  font-size: 14px;
  font-weight: 600;
  min-width: 20px;
  text-align: center;
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

.remark-section {
  background: #ffffff;
  margin-bottom: 12px;
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

.discount {
  color: #ff6b6b;
}

.checkout-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: #ffffff;
  padding: 16px;
  border-top: 1px solid #f5f5f5;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.price-info {
  display: flex;
  align-items: baseline;
  gap: 8px;
}

.total-price {
  font-size: 20px;
  font-weight: bold;
  color: #ff6b6b;
}
</style>