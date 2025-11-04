<template>
  <div class="address-edit">
    <!-- 顶部导航 -->
    <van-nav-bar
      :title="isEdit ? '编辑地址' : '添加地址'"
      left-arrow
      @click-left="goBack"
    >
      <template #right>
        <span class="save-btn" @click="saveAddress">保存</span>
      </template>
    </van-nav-bar>

    <!-- 地址表单 -->
    <div class="form-content">
      <van-form @submit="saveAddress">
        <van-cell-group inset>
          <van-field
            v-model="formData.contactName"
            label="收货人"
            placeholder="请输入收货人姓名"
            :rules="[{ required: true, message: '请输入收货人姓名' }]"
          />
          <van-field
            v-model="formData.contactPhone"
            label="手机号"
            type="tel"
            placeholder="请输入手机号"
            :rules="[
              { required: true, message: '请输入手机号' },
              { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号' }
            ]"
          />
          <van-field
            v-model="areaText"
            readonly
            label="所在地区"
            placeholder="请选择省市区"
            @click="showAreaPicker = true"
          />
          <van-field
            v-model="formData.detailAddress"
            label="详细地址"
            type="textarea"
            placeholder="请输入详细地址（街道、门牌号等）"
            rows="3"
            :rules="[{ required: true, message: '请输入详细地址' }]"
          />
        </van-cell-group>

        <!-- 设为默认地址 -->
        <div class="default-setting">
          <van-cell center title="设为默认地址">
            <template #right-icon>
              <van-switch v-model="formData.isDefault" />
            </template>
          </van-cell>
        </div>
      </van-form>
    </div>

    <!-- 地区选择器 -->
    <van-popup v-model:show="showAreaPicker" position="bottom" round>
      <van-area
        :area-list="areaList"
        @confirm="onAreaConfirm"
        @cancel="showAreaPicker = false"
      />
    </van-popup>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { areaList } from '@vant/area-data';
import { addressApi } from '@/api/address';

const router = useRouter()

// 接收路由传递的地址数据
const props = defineProps({
  addressData: {
    type: Object,
    default: null
  }
})

const isEdit = computed(() => !!props.addressData?.id)
const showAreaPicker = ref(false)

// 表单数据
const formData = ref({
  contactName: '',
  contactPhone: '',
  province: '',
  city: '',
  district: '',
  detailAddress: '',
  isDefault: false
})

// 地区文本显示
const areaText = computed(() => {
  const { province, city, district } = formData.value
  if (province && city && district) {
    return `${province} ${city} ${district}`
  }
  return ''
})

// 地区选择确认
const onAreaConfirm = ({ selectedOptions }) => {
  formData.value.province = selectedOptions[0]?.text || ''
  formData.value.city = selectedOptions[1]?.text || ''
  formData.value.district = selectedOptions[2]?.text || ''
  showAreaPicker.value = false
}

//新增调用api
  const addAddressApi = async () =>{
  try {
    await addressApi.addAddress(formData.value);
    showToast('地址添加成功')
  } catch (error) {
    showToast(error.message || "添加失败，请重试");
  }
  }

  //编辑地址调用api
  const updateAddressApi = async ()=>{
      try {
    await addressApi.updateAddress(props.addressData.id, formData.value);
    showToast('地址更新成功')
  } catch (error) {
    showToast(error.message || "更新失败，请重试");
  }
  }

// 保存地址
const saveAddress = async () => {
  // 验证表单
  if (!formData.value.contactName) {
    showToast('请输入收货人姓名')
    return
  }

  if (!formData.value.contactPhone) {
    showToast('请输入手机号')
    return
  }

  if (!/^1[3-9]\d{9}$/.test(formData.value.contactPhone)) {
    showToast('请输入正确的手机号')
    return
  }

  if (!formData.value.province || !formData.value.city || !formData.value.district) {
    showToast('请选择所在地区')
    return
  }

  if (!formData.value.detailAddress) {
    showToast('请输入详细地址')
    return
  }

    // 调用API保存地址
    if (isEdit.value) {
      await updateAddressApi()
    } else {
      await addAddressApi()
    }

    // 返回地址列表
    router.back()
}

// 返回
const goBack = () => {
  router.back()
}

onMounted(() => {
  // 如果是编辑模式，加载地址数据
  if (props.addressData) {
    // 将props数据复制到本地表单
    Object.assign(formData.value, {
      contactName: props.addressData.contactName,
      contactPhone: props.addressData.contactPhone,
      province: props.addressData.province,
      city: props.addressData.city,
      district: props.addressData.district,
      detailAddress: props.addressData.detailAddress,
      isDefault: props.addressData.isDefault
    })
  }
})
</script>

<style scoped>
.address-edit {
  min-height: 100vh;
  background: #f5f5f5;
}

.save-btn {
  color: #1989fa;
  font-size: 14px;
}

.form-content {
  padding: 12px;
}

.default-setting {
  margin-top: 12px;
}
</style>