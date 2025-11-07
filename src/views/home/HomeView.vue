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
        :text="category.tagName"
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
import { RESTAURANT_CATEGORIES } from '@/constants'
import { restaurantApi } from '@/api/restaurant'

const router = useRouter()
const searchKeyword = ref('')

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
    image: new URL('@/assets/images/restaurant1.jpg', import.meta.url).href,
    rating: 4.8,
    tags: ['川菜', '麻辣'],
    deliveryFee: 5,
    deliveryTime: 30
  },
  {
    id: 2,
    name: '粤式茶餐厅',
    image: new URL('@/assets/images/restaurant2.jpg', import.meta.url).href,
    rating: 4.6,
    tags: ['粤菜', '茶餐厅'],
    deliveryFee: 3,
    deliveryTime: 25
  },
  {
    id: 3,
    name: '日式料理',
    image: new URL('@/assets/images/restaurant3.jpg', import.meta.url).href,
    rating: 4.9,
    tags: ['日料', '寿司'],
    deliveryFee: 8,
    deliveryTime: 40
  }
])
  //分页
const pageInfo = {
  page:1,
  limit:5
}
// 搜索功能
const onSearch = () => {
  if (!searchKeyword.value.trim()) {
    showToast('请输入搜索关键词')
    return
  }
  // 实现搜索逻辑
    router.push({
    name: 'RestaurantList',
    query: {
      keyword: searchKeyword.value,
      ...pageInfo
    }
  })
}

// 分类点击
const onCategoryClick = (category) => {
  // 根据分类筛选餐厅
      router.push({
    name: 'RestaurantList',
    query: {
      tags:category.tagName,
      ...pageInfo
    }
  })
}

// 查看更多
const viewMore = () => {
  //查看更多热门的餐厅
        router.push({
    name: 'RestaurantList',
    query: {minRating:4, ...pageInfo}
  })
}

// 跳转到餐厅详情
const goToRestaurant = (restaurantId) => {
  router.push(`/restaurant/${restaurantId}`)
}

//加载餐厅标签
const loadTags = async () =>{
    try {
      const result = await restaurantApi.getRestaurantTag({tagType:'cuisine'})
      categories.value = result.data
  } catch (error) {
    showToast(error.message || "加载餐厅标签查询失败，请重试");
  }
}

//加载热门餐厅
const loadHotResaurants = async () =>{
      try {
      const result = await restaurantApi.getRestaurantList({minRating:4, ...pageInfo})

      //把图片都加上nerURL
      restaurants.value = result.data.map((item)=>{
        item.image = new URL(item.image,import.meta.url).href
        return item
      })
      console.log(restaurants.value,'kankan');
      
      
  } catch (error) {
    showToast(error.message || "加载热门餐厅查询失败，请重试");
  }
}

onMounted(() => {
  //首先加载首页餐厅图标
  loadTags();

  //然后加载首页热门餐厅
  loadHotResaurants();

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