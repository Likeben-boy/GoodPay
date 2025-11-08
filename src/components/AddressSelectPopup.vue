<template>
  <div class="address-select-popup">
    <div class="popup-header">
      <h3>选择收货地址</h3>
      <van-icon name="cross" @click="$emit('update:show', false)" />
    </div>

    <div class="address-list">
      <div
        v-for="addr in addressList"
        :key="addr.id"
        class="address-item"
        :class="{ active: selectedAddressId === addr.id }"
        @click="selectAddress(addr)"
      >
        <div class="address-content">
          <div class="address-header">
            <span class="contact">{{ addr.contactName }} {{ addr.contactPhone }}</span>
            <span class="address-tag" v-if="addr.isDefault">默认</span>
          </div>
          <div class="address-detail">{{ formatAddress(addr) }}</div>
        </div>
        <van-icon
          name="success"
          class="check-icon"
          v-if="selectedAddressId === addr.id"
          color="#ff6b6b"
        />
      </div>
    </div>

    </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { addressApi } from '@/api/address'

const props = defineProps({
  show: {
    type: Boolean,
    default: false
  },
  currentAddressId: {
    type: [String, Number],
    default: null
  }
})

const emit = defineEmits(['update:show', 'select'])

const addressList = ref([])
const selectedAddressId = computed(() => props.currentAddressId)

// 加载地址列表
const loadAddressList = async () => {
  try {
    // 调用地址列表接口
    const result = await addressApi.addressList()
    addressList.value = result.data
  } catch (error) {
    console.error('加载地址列表失败:', error)
    showToast('加载地址列表失败')
  }
}

// 选择地址
const selectAddress = (addr) => {
  emit('select', addr)
  emit('update:show', false)
}

// 格式化地址显示
const formatAddress = (addr) => {
  return `${addr.province}${addr.city}${addr.district}${addr.detailAddress}`
}

onMounted(() => {
  if (props.show) {
    loadAddressList()
  }
})
</script>

<style scoped>
.address-select-popup {
  height: 100%;
  display: flex;
  flex-direction: column;
  background: #f5f5f5;
}

.popup-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  background: white;
  border-bottom: 1px solid #eee;
}

.popup-header h3 {
  margin: 0;
  font-size: 18px;
  font-weight: bold;
}

.popup-header .van-icon {
  font-size: 20px;
  color: #666;
  cursor: pointer;
}

.address-list {
  flex: 1;
  overflow-y: auto;
  padding: 8px 0;
}

.address-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px;
  margin: 0 16px 8px;
  background: white;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
}

.address-item:hover {
  background: #fafafa;
}

.address-item.active {
  border: 1px solid #ff6b6b;
  background: #fff5f5;
}

.address-content {
  flex: 1;
  margin-right: 12px;
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
  color: #333;
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

.check-icon {
  font-size: 20px;
  flex-shrink: 0;
}

</style>