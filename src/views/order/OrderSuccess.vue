<template>
  <div class="order-success">
    
    <!-- <van-nav-bar title="订单成功" left-arrow @click-left="goBack" /> -->

    <div class="success-content">
      <div class="success-icon">
        <van-icon name="success" color="#07c160" size="64" />
      </div>

      <h2>订单提交成功！</h2>
      <p>您的订单已成功提交，商家正在准备您的美食</p>

      <div class="order-info">
        <div class="info-item">
          <span class="label">订单号</span>
          <span class="value">{{ orderNumber }}</span>
        </div>
        <div class="info-item">
          <span class="label">预计送达时间</span>
          <span class="value">{{ estimatedDeliveryTime }}</span>
        </div>
        <div class="info-item">
          <span class="label">实付金额</span>
          <span class="value price">¥{{ totalAmount }}</span>
        </div>
      </div>

      <div class="action-buttons">
        <van-button block type="primary" @click="viewOrderDetail" class="view-detail-btn">
          查看订单详情
        </van-button>
        <van-button block plain @click="goHome" class="go-home-btn">
          返回首页
        </van-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const orderNumber = ref('')
const estimatedDeliveryTime = ref('')
const totalAmount = ref(0)

onMounted(() => {
  // 生成订单号
  orderNumber.value = 'GP' + Date.now()

  // 计算预计送达时间（当前时间 + 30分钟）
  const now = new Date()
  now.setMinutes(now.getMinutes() + 30)
  estimatedDeliveryTime.value = now.toLocaleTimeString('zh-CN', {
    hour: '2-digit',
    minute: '2-digit'
  })

  // 从路由参数或状态管理获取订单金额
  // 这里使用默认值
  totalAmount.value = 93
})

const viewOrderDetail = () => {
  router.push(`/order/${orderNumber.value}`)
}

const goHome = () => {
  router.push('/')
}

// 返回上一页
const goBack = () => {
  router.back()
}
</script>

<style scoped>
.order-success {
  min-height: 100vh;
  background: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}


.success-content {
  background: white;
  border-radius: 12px;
  padding: 40px 24px;
  text-align: center;
  max-width: 320px;
  width: 100%;
}

.success-icon {
  margin-bottom: 24px;
}

.success-content h2 {
  margin: 0 0 12px 0;
  font-size: 24px;
  font-weight: bold;
  color: #333;
}

.success-content p {
  margin: 0 0 32px 0;
  font-size: 14px;
  color: #666;
  line-height: 1.5;
}

.order-info {
  background: #f9f9f9;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 32px;
  text-align: left;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  font-size: 14px;
}

.info-item:last-child {
  margin-bottom: 0;
}

.label {
  color: #666;
}

.value {
  color: #333;
  font-weight: 500;
}

.value.price {
  color: #ff6b6b;
  font-size: 16px;
  font-weight: bold;
}

.action-buttons {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.view-detail-btn {
  background: #ff6b6b;
  border-color: #ff6b6b;
}

.view-detail-btn:hover {
  background: #ff5252;
  border-color: #ff5252;
}

.go-home-btn {
  color: #666;
  border-color: #ddd;
}

.go-home-btn:hover {
  background: #f9f9f9;
}
</style>