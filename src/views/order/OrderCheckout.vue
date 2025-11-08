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
            <span class="contact">{{ address.contactName }} {{ address.contactPhone }}</span>
            <span class="address-tag" v-if="address.isDefault">默认</span>
          </div>
          <div class="address-detail">
            {{ personalAddress }}
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
      <div class="time-picker-header">
        <div class="picker-title">选择配送时间</div>
        <van-icon name="cross" @click="showTimePicker = false" />
      </div>
      <div class="time-options">
        <div
          v-for="(option, index) in deliveryTimeOptions"
          :key="index"
          class="time-option"
          :class="{ active: selectedDeliveryTime === option.text }"
          @click="selectDeliveryTime(option)"
        >
          <div class="time-text">{{ option.text }}</div>
          <van-icon
            name="success"
            v-if="selectedDeliveryTime === option.text"
            color="#ff6b6b"
          />
        </div>
      </div>
    </van-popup>

    <!-- 地址选择弹窗 -->
    <van-popup
      v-model:show="showAddressSelect"
      position="bottom"
      :style="{ height: '70%' }"
      round
    >
      <AddressSelectPopup
        :show="showAddressSelect"
        :current-address-id="address.id"
        @update:show="showAddressSelect = $event"
        @select="onAddressSelect"
      />
    </van-popup>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useCartStore } from '@/store/cart'
import { restaurantApi } from '@/api'
import { addressApi } from '@/api/address'
import { showToast } from 'vant'
import AddressSelectPopup from '@/components/AddressSelectPopup.vue'

const router = useRouter()
const route = useRoute()

// 初始化购物车 store
const cartStore = useCartStore()

const showTimePicker = ref(false)
const showAddressSelect = ref(false)
const selectedPayment = ref('wechat')
const orderNote = ref('')

// 餐厅信息
const restaurant = ref({
  id: null,
  name: '',
  image: '',
  deliveryFee: 0,
  deliveryTime: 0
})

// 收货地址
const address = ref({
  id: null,
  contactName: '',
  contactPhone: '',
  province: '',
  city:'',
  district:'',
  detailAddress:'',
  isDefault: false
})


// 订单商品 - 从购物车store获取
const orderItems = computed(() => cartStore.items)

// 配送时间选项 - 动态生成
const deliveryTimeOptions = ref([])
const selectedDeliveryTime = ref('立即送达') // 显示给用户看的文本
const deliveryTimeParam = ref('立即送达') // 实际提交给后端的参数

// 生成配送时间选项
const generateDeliveryTimeOptions = () => {
  const options = []
  const now = new Date()

  // 添加立即送达选项（如果营业时间内）
  const currentHour = now.getHours()
  if (currentHour >= 8 && currentHour < 22) {
    options.push({
      text: '立即送达',
      value: 'immediate',
      time: now.getTime()
    })
  }

  // 生成30分钟间隔的时间段选项
  const startTime = new Date(now.getTime() + 30 * 60 * 1000) // 30分钟后
  startTime.setMinutes(Math.ceil(startTime.getMinutes() / 30) * 30) // 向上取整到最近的30分钟

  const endTime = new Date(now)
  endTime.setHours(22, 0, 0, 0) // 营业结束时间22:00

  const currentTime = new Date(startTime)

  while (currentTime < endTime) {
    const nextTime = new Date(currentTime.getTime() + 30 * 60 * 1000)

    const timeStr = formatTimeRange(currentTime, nextTime)
    options.push({
      text: timeStr,
      value: `${formatTime(currentTime)}-${formatTime(nextTime)}`,
      time: currentTime.getTime()
    })

    currentTime.setTime(nextTime.getTime())
  }

  return options
}

// 格式化单个时间
const formatTime = (date) => {
  return `${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`
}

// 格式化时间范围
const formatTimeRange = (startTime, endTime) => {
  return `${formatTime(startTime)}-${formatTime(endTime)}送达`
}

// 初始化配送时间选项
const initDeliveryTimeOptions = () => {
  deliveryTimeOptions.value = generateDeliveryTimeOptions()

  // 默认选择第一个可用时间
  if (deliveryTimeOptions.value.length > 0) {
    selectedDeliveryTime.value = deliveryTimeOptions.value[0].text
    deliveryTimeParam.value = deliveryTimeOptions.value[0].value === 'immediate'
      ? '立即送达'
      : deliveryTimeOptions.value[0].value.split('-')[1]
  }
}

// 支付方式
const paymentMethods = ref([
  { id: 'wechat', name: '微信支付', icon: 'wechat', color: '#07c160' },
  { id: 'alipay', name: '支付宝', icon: 'alipay', color: '#1677ff' },
  { id: 'apple', name: 'Apple Pay', icon: 'apple', color: '#000000' }
])

// 计算费用
const subtotal = computed(() => {
  return cartStore.totalPrice
})

const total = computed(() => {
  return cartStore.totalPrice + restaurant.value.deliveryFee
})

// 选择收货地址
const selectAddress = () => {
  showAddressSelect.value = true
}

// 地址选择后的处理
const onAddressSelect = (selectedAddr) => {
  address.value = selectedAddr
  showToast('已选择收货地址')
}

// 选择配送时间
const selectDeliveryTime = (option) => {
  selectedDeliveryTime.value = option.text
  showTimePicker.value = false

  // 设置实际提交给后端的参数
  if (option.value === 'immediate') {
    deliveryTimeParam.value = '立即送达'
  } else {
    // 如果是时间范围，取开始时间作为参数
    const endTime = option.value.split('-')[0]
    deliveryTimeParam.value = endTime
  }
}

// 提交订单
const submitOrder = () => {
  if (!address.value.id) {
    showToast('请选择收货地址')
    return
  }

  if (cartStore.items.length === 0) {
    showToast('购物车为空，请添加商品')
    return
  }

  const orderData = {
    restaurantId: restaurant.value.id,
    addressId: address.value.id,
    items: cartStore.items,
    paymentMethod: selectedPayment.value,
    deliveryTime: deliveryTimeParam.value,
    note: orderNote.value,
    subtotal: cartStore.totalPrice,
    deliveryFee: restaurant.value.deliveryFee,
    total: cartStore.totalPrice + restaurant.value.deliveryFee
  }

  showToast('订单提交成功！')
  console.log('提交订单数据:', JSON.stringify(orderData))

  // TODO: 调用后端API提交订单
  // 清空购物车
  // cartStore.clearCart()

  // 跳转到订单详情页面
  // setTimeout(() => {
  //   router.push('/order/success')
  // }, 1500)
}

// 加载餐厅信息
const loadRestaurant = async (restaurantId) => {
  try {
    const result = await restaurantApi.getRestaurantDetail({ id: restaurantId })
    // 把图片都加上nerURL
    result.data.image = new URL(result.data.image, import.meta.url).href
    restaurant.value = result.data
  } catch (error) {
    showToast(error.message || '加载餐厅信息失败，请重试')
    // 使用路由参数作为备用
    restaurant.value = {
      id: restaurantId,
      name: route.query.restaurantName || '餐厅',
      image: '/images/restaurant-default.jpg',
      deliveryFee: Number(route.query.deliveryFee) || 5,
      deliveryTime: 30
    }
  }
}

// 格式化地址显示
const formatAddress = (addr) => {
  if (!addr.province && !addr.city && !addr.district && !addr.detailAddress) {
    return '请选择收货地址'
  }
  return `${addr.province || ''}${addr.city || ''}${addr.district || ''}${addr.detailAddress || ''}`
}

// 计算属性：完整的地址字符串
const personalAddress = computed(() => formatAddress(address.value))

// 加载默认收货地址
const loadDefaultAddress = async () => {
  try {
    // TODO: 调用默认收货地址接口
    const result = await addressApi.getDefaultAddress()
    address.value = result.data
  } catch (error) {
    console.error('加载默认收货地址失败:', error)
    // 临时使用默认数据，按照实际返回格式
    address.value = {
      id: 5,
      contactName: '李四',
      contactPhone: '18088312002',
      province: '天津市',
      city: '天津市',
      district: '和平区',
      detailAddress: '和平小区116号',
      isDefault: true,
      userId: 1
    }
  }
}

// 返回上一页
const goBack = () => {
  router.back()
}

onMounted(async () => {
  // 初始化配送时间选项
  initDeliveryTimeOptions()

  const restaurantId = route.query.restaurantId
  if (restaurantId) {
    await loadRestaurant(restaurantId)
  } else {
    showToast('缺少餐厅信息')
    router.back()
    return
  }

  // 加载默认收货地址
  await loadDefaultAddress()

  // 检查购物车是否有商品
  if (cartStore.items.length === 0) {
    showToast('购物车为空，请先添加商品')
    setTimeout(() => {
      router.back()
    }, 1500)
  }
})
</script>

<style scoped>
.order-checkout {
  min-height: 100vh;
  background: #f5f5f5;
  padding-bottom: 130px; /* 80px + 50px 导航栏高度 */
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
  bottom: 50px; /* 在导航栏上方，van-tabbar通常高度为50px */
  left: 0;
  right: 0;
  background: white;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px;
  box-shadow: 0 -2px 8px rgba(0, 0, 0, 0.1);
  z-index: 100;
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

/* 配送时间选择器样式 */
.time-picker-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  background: white;
  border-bottom: 1px solid #eee;
}

.picker-title {
  font-size: 18px;
  font-weight: bold;
}

.time-picker-header .van-icon {
  font-size: 20px;
  color: #666;
  cursor: pointer;
}

.time-options {
  max-height: 300px;
  overflow-y: auto;
  background: #f5f5f5;
}

.time-option {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px;
  margin: 8px 16px;
  background: white;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
}

.time-option:hover {
  background: #fafafa;
}

.time-option.active {
  border: 1px solid #ff6b6b;
  background: #fff5f5;
}

.time-text {
  font-size: 16px;
  color: #333;
}

.time-option .van-icon {
  font-size: 20px;
  flex-shrink: 0;
}
</style>