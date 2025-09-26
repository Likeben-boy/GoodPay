<template>
  <div class="home">
    <!-- 顶部搜索栏 -->
    <van-search
      v-model="searchKeyword"
      placeholder="搜索餐厅或菜品"
      shape="round"
      background="#ffffff"
      @search="onSearch"
    />

    <!-- 轮播图 -->
    <van-swipe class="banner" :autoplay="3000" indicator-color="white">
      <van-swipe-item v-for="(banner, index) in banners" :key="index">
        <img :src="banner.image" :alt="banner.title" />
      </van-swipe-item>
    </van-swipe>

    <!-- 分类导航 -->
    <van-grid class="categories" :column-num="4" :border="false">
      <van-grid-item
        v-for="category in categories"
        :key="category.id"
        :icon="category.icon"
        :text="category.name"
        @click="onCategoryClick(category)"
      />
    </van-grid>

    <!-- 推荐餐厅 -->
    <div class="section">
      <div class="section-header">
        <h3>推荐餐厅</h3>
        <span class="more" @click="viewMore">查看更多</span>
      </div>

      <div class="restaurant-list">
        <div
          v-for="restaurant in restaurants"
          :key="restaurant.id"
          class="restaurant-card"
          @click="goToRestaurant(restaurant.id)"
        >
          <img :src="restaurant.image" :alt="restaurant.name" class="restaurant-image" />
          <div class="restaurant-info">
            <h4>{{ restaurant.name }}</h4>
            <div class="restaurant-meta">
              <span class="rating">⭐ {{ restaurant.rating }}</span>
              <span class="distance">{{ formatDistance(restaurant.distance) }}</span>
            </div>
            <div class="restaurant-tags">
              <span v-for="tag in restaurant.tags" :key="tag" class="tag">{{ tag }}</span>
            </div>
            <div class="delivery-info">
              <span class="delivery-fee">配送费 ¥{{ restaurant.deliveryFee }}</span>
              <span class="delivery-time">{{ restaurant.deliveryTime }}分钟</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showToast } from 'vant'
import { formatDistance } from '@/utils'
import { RESTAURANT_CATEGORIES } from '@/constants'

const router = useRouter()
const searchKeyword = ref('')
const activeTab = ref(0)

// 轮播图数据
const banners = ref([
  { id: 1, image: new URL('@/assets/images/banner1.jpg', import.meta.url).href, title: '新用户专享优惠' },
  { id: 2, image: new URL('@/assets/images/banner2.webp', import.meta.url).href, title: '限时折扣活动' },
  { id: 3, image: new URL('@/assets/images/banner3.jpg', import.meta.url).href, title: '热门餐厅推荐' }
])

// 分类数据
const categories = ref(RESTAURANT_CATEGORIES)

// 餐厅数据
const restaurants = ref([
  {
    id: 1,
    name: '川味小厨',
    image: '/images/restaurant1.jpg',
    rating: 4.8,
    distance: 1.2,
    tags: ['川菜', '麻辣'],
    deliveryFee: 5,
    deliveryTime: 30
  },
  {
    id: 2,
    name: '粤式茶餐厅',
    image: '/images/restaurant2.jpg',
    rating: 4.6,
    distance: 0.8,
    tags: ['粤菜', '茶餐厅'],
    deliveryFee: 3,
    deliveryTime: 25
  },
  {
    id: 3,
    name: '日式料理',
    image: '/images/restaurant3.jpg',
    rating: 4.9,
    distance: 2.1,
    tags: ['日料', '寿司'],
    deliveryFee: 8,
    deliveryTime: 40
  }
])

// 搜索功能
const onSearch = () => {
  if (!searchKeyword.value.trim()) {
    showToast('请输入搜索关键词')
    return
  }
  // TODO: 实现搜索逻辑
  showToast(`搜索: ${searchKeyword.value}`)
}

// 分类点击
const onCategoryClick = (category) => {
  showToast(`查看${category.name}分类`)
  // TODO: 根据分类筛选餐厅
}

// 查看更多
const viewMore = () => {
  showToast('查看更多餐厅')
}

// 跳转到餐厅详情
const goToRestaurant = (restaurantId) => {
  router.push(`/restaurant/${restaurantId}`)
}

onMounted(() => {
  // TODO: 加载餐厅数据
})
</script>

<style scoped>
.home {
  padding-bottom: 50px;
}

.banner {
  height: 160px;
  margin-bottom: 16px;
}

.banner img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.categories {
  margin-bottom: 20px;
}

.section {
  padding: 0 16px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.section-header h3 {
  margin: 0;
  font-size: 18px;
  font-weight: bold;
}

.more {
  color: #969799;
  font-size: 14px;
}

.restaurant-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.restaurant-card {
  display: flex;
  background: #ffffff;
  border-radius: 8px;
  padding: 12px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  cursor: pointer;
}

.restaurant-image {
  width: 80px;
  height: 80px;
  border-radius: 8px;
  object-fit: cover;
  margin-right: 12px;
}

.restaurant-info {
  flex: 1;
}

.restaurant-info h4 {
  margin: 0 0 4px 0;
  font-size: 16px;
  font-weight: 600;
}

.restaurant-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px;
}

.rating {
  color: #ff6b6b;
  font-size: 14px;
}

.distance {
  color: #969799;
  font-size: 12px;
}

.restaurant-tags {
  display: flex;
  gap: 4px;
  margin-bottom: 4px;
}

.tag {
  background: #f5f5f5;
  color: #666;
  font-size: 12px;
  padding: 2px 6px;
  border-radius: 4px;
}

.delivery-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: #666;
  font-size: 12px;
}

.delivery-fee {
  color: #333;
}

.delivery-time {
  color: #969799;
}
</style>