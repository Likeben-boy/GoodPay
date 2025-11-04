<template>
  <div class="order-checkout">
    <!-- 顶部导航 -->
    <van-nav-bar title="订单结算" left-arrow @click-left="goBack" />

    <div class="checkout-content">
      <div class="restaurant-info">
        <img :src="restaurant.image" :alt="restaurant.name" class="restaurant-image" />
        <div class="restaurant-details">
          <h3>{{ restaurant.name }}</h3>
          <div class="delivery-info">
            <span>预计 {{ restaurant.deliveryTime }}分钟送达</span>
            <span>配送费 ¥{{ restaurant.deliveryFee }}</span>
          </div>
        </div>
      </div>

      <!-- 收货地址 -->
      <div class="address-section" @click="selectAddress">
        <div class="address-info">
          <div class="address-header">
            <span class="contact">{{ address.name }} {{ address.phone }}</span>
            <span class="address-tag" v-if="address.isDefault">默认</span>
          </div>
          <div class="address-detail">
            {{ address.address }}
          </div>
        </div>
        <van-icon name="arrow" />
      </div>

      <!-- 配送时间 -->
      <div class="delivery-time-section" @click="showTimePicker = true">
        <div class="section-title">配送时间</div>
        <div class="section-content">
          <span>{{ selectedDeliveryTime }}</span>
          <van-icon name="arrow" />
        </div>
      </div>

      <!-- 订单商品 -->
      <div class="order-items-section">
        <div class="section-title">订单商品</div>
        <div class="order-items">
          <div v-for="item in orderItems" :key="item.id" class="order-item">
            <img :src="item.image" :alt="item.name" class="item-image" />
            <div class="item-info">
              <h4>{{ item.name }}</h4>
              <span class="item-spec" v-if="item.selectedSpec">{{ item.selectedSpec }}</span>
            </div>
            <div class="item-price-quantity">
              <span class="price">¥{{ item.price }}</span>
              <span class="quantity">x{{ item.quantity }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 支付方式 -->
      <div class="payment-section">
        <div class="section-title">支付方式</div>
        <div class="payment-methods">
          <div
            v-for="method in paymentMethods"
            :key="method.id"
            class="payment-method"
            :class="{ active: selectedPayment === method.id }"
            @click="selectedPayment = method.id"
          >
            <van-icon :name="method.icon" :color="method.color" />
            <span>{{ method.name }}</span>
            <van-icon name="success" v-if="selectedPayment === method.id" color="#ff6b6b" />
          </div>
        </div>
      </div>

      <!-- 备注 -->
      <div class="note-section">
        <div class="section-title">订单备注</div>
        <van-field
          v-model="orderNote"
          placeholder="请输入订单备注（选填）"
          rows="2"
          type="textarea"
          maxlength="100"
          show-word-limit
        />
      </div>

      <!-- 费用明细 -->
      <div class="price-details">
        <div class="price-item">
          <span>商品总价</span>
          <span>¥{{ subtotal }}</span>
        </div>
        <div class="price-item">
          <span>配送费</span>
          <span>¥{{ restaurant.deliveryFee }}</span>
        </div>
        <div class="price-item total">
          <span>实付金额</span>
          <span class="total-price">¥{{ total }}</span>
        </div>
      </div>
    </div>

    <!-- 底部结算栏 -->
    <div class="checkout-footer">
      <div class="price-summary">
        <span>实付金额</span>
        <span class="total-price">¥{{ total }}</span>
      </div>
      <div class="submit-btn" @click="submitOrder">提交订单</div>
    </div>

    <!-- 配送时间选择器 -->
    <van-popup v-model:show="showTimePicker" position="bottom" round>
      <van-picker
        :columns="deliveryTimeOptions"
        @confirm="onTimeConfirm"
        @cancel="showTimePicker = false"
      />
    </van-popup>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const showTimePicker = ref(false)
const selectedPayment = ref('wechat')
const orderNote = ref('')

// 餐厅信息
const restaurant = ref({
  id: 1,
  name: '川味小厨',
  image: '/images/restaurant1.jpg',
  deliveryFee: 5,
  deliveryTime: 30
})

// 收货地址
const address = ref({
  id: 1,
  name: '张三',
  phone: '138****8888',
  address: '北京市朝阳区某某街道某某小区1号楼1单元101室',
  isDefault: true
})

// 订单商品（从购物车传递过来的数据）
const orderItems = ref([
  {
    id: 1,
    name: '麻婆豆腐',
    image: '/images/dish1.jpg',
    price: 28,
    quantity: 2,
    selectedSpec: ''
  },
  {
    id: 2,
    name: '宫保鸡丁',
    image: '/images/dish2.jpg',
    price: 32,
    quantity: 1,
    selectedSpec: '微辣'
  }
])

// 配送时间选项
const deliveryTimeOptions = ref([
  '立即送达',
  '30分钟后送达',
  '45分钟后送达',
  '1小时后送达',
  '18:00-18:30送达',
  '18:30-19:00送达',
  '19:00-19:30送达'
])

const selectedDeliveryTime = ref('立即送达')

// 支付方式
const paymentMethods = ref([
  { id: 'wechat', name: '微信支付', icon: 'wechat', color: '#07c160' },
  { id: 'alipay', name: '支付宝', icon: 'alipay', color: '#1677ff' },
  { id: 'apple', name: 'Apple Pay', icon: 'apple', color: '#000000' }
])

// 计算费用
const subtotal = computed(() => {
  return orderItems.value.reduce((total, item) => total + item.price * item.quantity, 0)
})

const total = computed(() => {
  return subtotal.value + restaurant.value.deliveryFee
})

// 选择收货地址
const selectAddress = () => {
  showToast('选择收货地址')
  // TODO: 跳转到地址选择页面
}

// 确认配送时间
const onTimeConfirm = ({ selectedValues }) => {
  selectedDeliveryTime.value = selectedValues[0]
  showTimePicker.value = false
}

// 提交订单
const submitOrder = () => {
  const orderData = {
    restaurantId: restaurant.value.id,
    addressId: address.value.id,
    items: orderItems.value,
    paymentMethod: selectedPayment.value,
    deliveryTime: selectedDeliveryTime.value,
    note: orderNote.value,
    subtotal: subtotal.value,
    deliveryFee: restaurant.value.deliveryFee,
    total: total.value
  }

  showToast('订单提交成功！')
  console.log('提交订单数据:', orderData)

  // TODO: 调用后端API提交订单
  // 跳转到订单详情页面
  setTimeout(() => {
    router.push('/order/success')
  }, 1500)
}

// 返回上一页
const goBack = () => {
  router.back()
}

onMounted(() => {
  // TODO: 从路由参数获取订单数据
})
</script>

<style scoped>
.order-checkout {
  min-height: 100vh;
  background: #f5f5f5;
  padding-bottom: 80px;
}


.checkout-content {
  padding: 16px;
}

.restaurant-info {
  display: flex;
  align-items: center;
  gap: 12px;
  background: white;
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 12px;
}

.restaurant-image {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  object-fit: cover;
}

.restaurant-details h3 {
  margin: 0 0 8px 0;
  font-size: 16px;
  font-weight: bold;
}

.delivery-info {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #666;
}

.address-section,
.delivery-time-section,
.order-items-section,
.payment-section,
.note-section {
  background: white;
  border-radius: 8px;
  margin-bottom: 12px;
  padding: 16px;
  cursor: pointer;
}

.section-title {
  font-size: 16px;
  font-weight: bold;
  margin-bottom: 12px;
}

.address-info {
  flex: 1;
}

.address-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 4px;
}

.contact {
  font-size: 16px;
  font-weight: bold;
}

.address-tag {
  background: #ff6b6b;
  color: white;
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 12px;
}

.address-detail {
  font-size: 14px;
  color: #666;
  line-height: 1.4;
}

.section-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.order-items {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.order-item {
  display: flex;
  align-items: center;
  gap: 12px;
}

.item-image {
  width: 50px;
  height: 50px;
  border-radius: 6px;
  object-fit: cover;
}

.item-info {
  flex: 1;
}

.item-info h4 {
  margin: 0 0 4px 0;
  font-size: 14px;
  font-weight: 600;
}

.item-spec {
  font-size: 12px;
  color: #666;
}

.item-price-quantity {
  text-align: right;
}

.price {
  color: #ff6b6b;
  font-size: 14px;
  font-weight: bold;
  display: block;
  margin-bottom: 2px;
}

.quantity {
  font-size: 12px;
  color: #666;
}

.payment-methods {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.payment-method {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border: 1px solid #eee;
  border-radius: 8px;
  cursor: pointer;
}

.payment-method.active {
  border-color: #ff6b6b;
  background: #fff5f5;
}

.note-section {
  cursor: default;
}

.price-details {
  background: white;
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 12px;
}

.price-item {
  display: flex;
  justify-content: space-between;
  font-size: 14px;
  margin-bottom: 8px;
  color: #666;
}

.price-item.total {
  color: #333;
  font-weight: bold;
  border-top: 1px solid #eee;
  padding-top: 8px;
  margin-top: 8px;
}

.total-price {
  color: #ff6b6b;
  font-size: 18px;
  font-weight: bold;
}

.checkout-footer {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: white;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px;
  box-shadow: 0 -2px 8px rgba(0, 0, 0, 0.1);
}

.price-summary {
  display: flex;
  align-items: baseline;
  gap: 8px;
}

.submit-btn {
  background: #ff6b6b;
  color: white;
  padding: 12px 32px;
  border-radius: 24px;
  font-weight: bold;
  cursor: pointer;
}

.submit-btn:hover {
  background: #ff5252;
}
</style>