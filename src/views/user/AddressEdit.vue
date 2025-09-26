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
            v-model="formData.name"
            label="收货人"
            placeholder="请输入收货人姓名"
            :rules="[{ required: true, message: '请输入收货人姓名' }]"
          />
          <van-field
            v-model="formData.phone"
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
            v-model="formData.detail"
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
import { useRouter, useRoute } from 'vue-router'
import { showToast } from 'vant'

const router = useRouter()
const route = useRoute()

const isEdit = computed(() => route.params.id !== undefined)
const showAreaPicker = ref(false)

// 表单数据
const formData = ref({
  name: '',
  phone: '',
  province: '',
  city: '',
  district: '',
  detail: '',
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

// 模拟地区数据
const areaList = ref({
  province_list: {
    '110000': '北京市',
    '310000': '上海市',
    '440000': '广东省',
    '330000': '浙江省'
  },
  city_list: {
    '110100': '北京市',
    '310100': '上海市',
    '440100': '广州市',
    '440300': '深圳市',
    '330100': '杭州市'
  },
  county_list: {
    '110101': '东城区',
    '110102': '西城区',
    '110105': '朝阳区',
    '110106': '丰台区',
    '310101': '黄浦区',
    '310104': '徐汇区',
    '310105': '长宁区',
    '310106': '静安区',
    '440103': '荔湾区',
    '440104': '越秀区',
    '440106': '天河区',
    '440305': '南山区',
    '330102': '上城区',
    '330103': '下城区',
    '330104': '江干区',
    '330105': '拱墅区'
  }
})

// 地区选择确认
const onAreaConfirm = ({ selectedOptions }) => {
  formData.value.province = selectedOptions[0]?.text || ''
  formData.value.city = selectedOptions[1]?.text || ''
  formData.value.district = selectedOptions[2]?.text || ''
  showAreaPicker.value = false
}

// 保存地址
const saveAddress = () => {
  // 验证表单
  if (!formData.value.name) {
    showToast('请输入收货人姓名')
    return
  }

  if (!formData.value.phone) {
    showToast('请输入手机号')
    return
  }

  if (!/^1[3-9]\d{9}$/.test(formData.value.phone)) {
    showToast('请输入正确的手机号')
    return
  }

  if (!formData.value.province || !formData.value.city || !formData.value.district) {
    showToast('请选择所在地区')
    return
  }

  if (!formData.value.detail) {
    showToast('请输入详细地址')
    return
  }

  // TODO: 调用API保存地址
  if (isEdit.value) {
    showToast('地址更新成功')
  } else {
    showToast('地址添加成功')
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
  if (isEdit.value) {
    const addressId = route.params.id
    // TODO: 根据ID加载地址数据
    // 这里使用模拟数据
    formData.value = {
      name: '张三',
      phone: '138****5678',
      province: '北京市',
      city: '朝阳区',
      district: '三里屯街道',
      detail: '工体北路8号院1号楼1单元101室',
      isDefault: true
    }
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