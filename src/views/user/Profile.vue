<template>
  <div class="profile">
    <!-- 顶部导航在三大标签页主页面时不需要导航栏 -->
    <!-- <van-nav-bar title="个人中心" left-arrow @click-left="goBack" /> -->

    <!-- 用户信息 -->
    <div class="user-section">
      <div class="user-info">
        <div class="avatar-container">
          <img :src="userInfo.avatar" :alt="userInfo.username" class="avatar" />
          <div class="avatar-edit" @click="editAvatar">
            <van-icon name="photograph" size="12" />
          </div>
        </div>
        <div class="user-details">
          <h3>{{ userInfo.nickname }}</h3>
          <p>{{ userInfo.phone }}</p>
        </div>
        <van-icon name="arrow" class="edit-icon" @click="editProfile" />
      </div>
    </div>

    <!-- 订单统计 -->
    <div class="order-stats">
      <div class="stat-item" @click="goToOrders('all')">
        <span class="stat-number">{{ orderStats.total }}</span>
        <span class="stat-label">全部订单</span>
      </div>
      <div class="stat-item" @click="goToOrders('pending')">
        <span class="stat-number">{{ orderStats.pending }}</span>
        <span class="stat-label">待支付</span>
      </div>
      <div class="stat-item" @click="goToOrders('processing')">
        <span class="stat-number">{{ orderStats.processing }}</span>
        <span class="stat-label">配送中</span>
      </div>
      <div class="stat-item" @click="goToOrders('completed')">
        <span class="stat-number">{{ orderStats.completed }}</span>
        <span class="stat-label">已完成</span>
      </div>
    </div>

    <!-- 功能菜单 -->
    <div class="menu-section">
      <div class="menu-group">
        <div class="menu-item" @click="goToAddress">
          <van-icon name="location-o" color="#1989fa" />
          <span>收货地址</span>
          <van-icon name="arrow" />
        </div>
        <div class="menu-item" @click="goToFavorite">
          <van-icon name="like-o" color="#ff6b6b" />
          <span>我的收藏</span>
          <van-icon name="arrow" />
        </div>
        <div class="menu-item" @click="goToCoupon">
          <van-icon name="coupon-o" color="#ff976a" />
          <span>优惠券</span>
          <div class="menu-right">
            <span class="badge">{{ couponCount }}张可用</span>
            <van-icon name="arrow" />
          </div>
        </div>
      </div>

      <div class="menu-group">
        <div class="menu-item" @click="goToWallet">
          <van-icon name="balance-pay" color="#07c160" />
          <span>我的钱包</span>
          <div class="menu-right">
            <span class="wallet-balance">¥{{ walletBalance }}</span>
            <van-icon name="arrow" />
          </div>
        </div>
        <div class="menu-item" @click="goToSecurity">
          <van-icon name="shield-o" color="#969799" />
          <span>账号安全</span>
          <van-icon name="arrow" />
        </div>
      </div>

      <div class="menu-group">
        <div class="menu-item" @click="goToHelp">
          <van-icon name="question-o" color="#1989fa" />
          <span>帮助中心</span>
          <van-icon name="arrow" />
        </div>
        <div class="menu-item" @click="goToFeedback">
          <van-icon name="chat-o" color="#ff6b6b" />
          <span>意见反馈</span>
          <van-icon name="arrow" />
        </div>
        <div class="menu-item" @click="goToAbout">
          <van-icon name="info-o" color="#969799" />
          <span>关于我们</span>
          <van-icon name="arrow" />
        </div>
      </div>
    </div>

    <!-- 退出登录 -->
    <div class="logout-section">
      <van-button type="danger" block @click="logout">退出登录</van-button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/store/user'

const router = useRouter()
const userStore = useUserStore();

// 用户信息
const userInfo = ref(userStore.userInfo)

// 订单统计
const orderStats = ref({
  total: 15,
  pending: 2,
  processing: 1,
  completed: 12
})

// 优惠券数量
const couponCount = ref(3)

// 钱包余额
const walletBalance = ref(128.50)

// 编辑头像
const editAvatar = () => {
  showToast('功能开发中...')
}

// 编辑资料
const editProfile = () => {
  showToast('功能开发中...')
}

// 跳转到订单页面
const goToOrders = (status) => {
  router.push('/order')
}

// 跳转到收货地址
const goToAddress = () => {
  router.push('/user/address')
}

// 跳转到收藏
const goToFavorite = () => {
  showToast('功能开发中...')
}

// 跳转到优惠券
const goToCoupon = () => {
  showToast('功能开发中...')
}

// 跳转到钱包
const goToWallet = () => {
  showToast('功能开发中...')
}

// 跳转到安全设置
const goToSecurity = () => {
  showToast('功能开发中...')
}

// 跳转到帮助中心
const goToHelp = () => {
  showToast('功能开发中...')
}

// 跳转到意见反馈
const goToFeedback = () => {
  showToast('功能开发中...')
}

// 跳转到关于我们
const goToAbout = () => {
  showToast('功能开发中...')
}

// 返回
const goBack = () => {
  router.back()
}

// 退出登录
const logout = () => {
  showConfirmDialog({
    title: '确认退出',
    message: '您确定要退出登录吗？',
  })
    .then(() => {
      // 清除用户信息
      localStorage.removeItem('token')
      showToast('退出成功')
      router.push('/login')
    })
    .catch(() => {
      // 取消退出
    })
}

onMounted(() => {
  // TODO: 加载用户信息
})
</script>

<style scoped>
.profile {
  min-height: 100vh;
  background: #f5f5f5;
}

.user-section {
  background: #ffffff;
  padding: 20px 16px;
  margin-bottom: 12px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 16px;
}

.avatar-container {
  position: relative;
  width: 60px;
  height: 60px;
}

.avatar {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  object-fit: cover;
}

.avatar-edit {
  position: absolute;
  bottom: 0;
  right: 0;
  background: #1989fa;
  color: white;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  border: 2px solid #ffffff;
}

.user-details {
  flex: 1;
}

.user-details h3 {
  margin: 0 0 4px 0;
  font-size: 18px;
  font-weight: bold;
}

.user-details p {
  margin: 0;
  font-size: 14px;
  color: #969799;
}

.edit-icon {
  color: #969799;
  cursor: pointer;
}

.order-stats {
  display: flex;
  background: #ffffff;
  padding: 20px 0;
  margin-bottom: 12px;
}

.stat-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  cursor: pointer;
}

.stat-number {
  font-size: 20px;
  font-weight: bold;
  color: #333;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 12px;
  color: #969799;
}

.menu-section {
  padding: 0 16px;
}

.menu-group {
  background: #ffffff;
  border-radius: 8px;
  margin-bottom: 12px;
  overflow: hidden;
}

.menu-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  cursor: pointer;
  border-bottom: 1px solid #f5f5f5;
}

.menu-item:last-child {
  border-bottom: none;
}

.menu-item span {
  flex: 1;
  font-size: 14px;
  color: #333;
}

.menu-right {
  display: flex;
  align-items: center;
  gap: 8px;
}

.badge {
  font-size: 12px;
  color: #ff6b6b;
}

.wallet-balance {
  font-size: 14px;
  font-weight: bold;
  color: #ff6b6b;
}

.logout-section {
  padding: 20px 16px;
}
</style>