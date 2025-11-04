<template>
  <div class="address-list">
    <!-- 顶部导航 -->
    <van-nav-bar title="收货地址" left-arrow @click-left="goBack">
      <template #right>
        <span class="add-btn" @click="goToAddAddress">添加</span>
      </template>
    </van-nav-bar>

    <!-- 地址列表 -->
    <div class="address-content">
      <div v-if="addresses.length === 0" class="empty-state">
        <van-icon name="location-o" size="48" color="#ddd" />
        <p>暂无收货地址</p>
        <van-button type="primary" @click="goToAddAddress">添加新地址</van-button>
      </div>

      <div v-else class="address-items">
        <div
          v-for="address in addresses"
          :key="address.id"
          class="address-item"
          @click="selectAddress(address)"
        >
          <div class="address-header">
            <div class="contact-info">
              <span class="name">{{ address.contactName }}</span>
              <span class="phone">{{ address.contactPhone }}</span>
              <span v-if="address.isDefault" class="default-tag">默认</span>
            </div>
            <div class="address-actions">
              <van-icon name="edit" @click.stop="editAddress(address)" />
              <van-icon name="delete-o" @click.stop="deleteAddress(address)" />
            </div>
          </div>
          <div class="address-detail">
            {{ address.province }}{{ address.city }}{{ address.district }}{{ address.detail }}
          </div>
        </div>
      </div>
    </div>

    <!-- 底部添加按钮 -->
    <div class="bottom-add-btn">
      <van-button type="primary" block @click="goToAddAddress">添加新地址</van-button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { addressApi } from '@/api/address'

const router = useRouter()
const route = useRoute()

// 地址列表
const addresses = ref([
  {
    id: 1,
    contactName: '张三',
    contactPhone: '138****5679',
    province: '北京市',
    city: '朝阳区',
    district: '三里屯街道',
    detailAddress: '工体北路8号院1号楼1单元101室',
    isDefault: true
  }
])

// 选择地址（用于订单结算）
const selectAddress = (address) => {
  if (route.query.from === 'checkout') {
    // 如果是从订单结算页面来的，选择地址后返回
    router.back()
  }
}

// 编辑地址
const editAddress = (address) => {
  router.push({
    name: 'AddressEdit',
    query: {
      id: address.id,
      contactName: address.contactName,
      contactPhone: address.contactPhone,
      province: address.province,
      city: address.city,
      district: address.district,
      detailAddress: address.detailAddress,
      isDefault: address.isDefault
    }
  })
}

// 删除地址
const deleteAddress = (address) => {
  showConfirmDialog({
    title: '删除地址',
    message: '确定要删除这个收货地址吗？',
  })
    .then(() => {
      const index = addresses.value.findIndex(a => a.id === address.id)
      if (index > -1) {
        addresses.value.splice(index, 1)
        showToast('删除成功')
      }
    })
    .catch(() => {
      // 取消删除
    })
}

// 跳转到添加地址页面
const goToAddAddress = () => {
  router.push('/user/address/add')
}

// 返回
const goBack = () => {
  router.back()
}

// 查询地址列表
const addressListApi = async () => {
  try {
    const result = await addressApi.addressList();
    //存入登陆信息
    addresses.value = result.data
  } catch (error) {
    showToast(error.message || "查询失败，请重试");
  }
};


onMounted( () => {
  addressListApi();
})
</script>

<style scoped>
.address-list {
  min-height: 100vh;
  background: #f5f5f5;
}

.add-btn {
  color: #1989fa;
  font-size: 14px;
}

.address-content {
  padding: 12px;
  padding-bottom: 80px;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 400px;
  color: #ddd;
}

.empty-state p {
  margin: 16px 0;
  font-size: 14px;
}

.address-items {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.address-item {
  background: white;
  border-radius: 8px;
  padding: 16px;
  cursor: pointer;
}

.address-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 8px;
}

.contact-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.name {
  font-size: 16px;
  font-weight: 600;
  color: #333;
}

.phone {
  font-size: 14px;
  color: #666;
}

.default-tag {
  background: #ff6b6b;
  color: white;
  font-size: 12px;
  padding: 2px 6px;
  border-radius: 4px;
}

.address-actions {
  display: flex;
  gap: 12px;
  color: #666;
  font-size: 18px;
}

.address-detail {
  font-size: 14px;
  color: #333;
  line-height: 1.4;
}

.bottom-add-btn {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: white;
  padding: 12px 16px;
  border-top: 1px solid #eee;
}
</style>