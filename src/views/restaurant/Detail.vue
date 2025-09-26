<template>
  <div class="restaurant-detail">
    <!-- 餐厅头部信息 -->
    <div class="restaurant-header">
      <img :src="restaurant.image" :alt="restaurant.name" class="restaurant-image" />
      <div class="restaurant-info">
        <h2>{{ restaurant.name }}</h2>
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

    <!-- 菜品分类 -->
    <van-tabs v-model:active="activeCategory" class="category-tabs">
      <van-tab v-for="category in categories" :key="category.id" :title="category.name">
        <div class="menu-section">
          <h3>{{ category.name }}</h3>
          <div class="dish-list">
            <div
              v-for="dish in category.dishes"
              :key="dish.id"
              class="dish-card"
            >
              <img :src="dish.image" :alt="dish.name" class="dish-image" />
              <div class="dish-info">
                <h4>{{ dish.name }}</h4>
                <p class="dish-description">{{ dish.description }}</p>
                <div class="dish-price-action">
                  <span class="price">¥{{ dish.price }}</span>
                  <van-button
                    type="primary"
                    size="small"
                    @click="addToCart(dish)"
                  >
                    加入购物车
                  </van-button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </van-tab>
    </van-tabs>

    <!-- 购物车悬浮按钮 -->
    <div class="cart-float" @click="goToCart">
      <van-badge :content="cartItemCount" :show-zero="false">
        <van-icon name="cart-o" size="24" />
      </van-badge>
      <span class="cart-total">¥{{ cartTotal }}</span>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { showToast } from 'vant'
import { formatDistance } from '@/utils'

const route = useRoute()
const router = useRouter()
const activeCategory = ref(0)

// 餐厅信息
const restaurant = ref({
  id: route.params.id,
  name: '川味小厨',
  image: '/images/restaurant1.jpg',
  rating: 4.8,
  distance: 1.2,
  tags: ['川菜', '麻辣'],
  deliveryFee: 5,
  deliveryTime: 30
})

// 菜品分类
const categories = ref([
  {
    id: 1,
    name: '热销菜品',
    dishes: [
      {
        id: 1,
        name: '麻婆豆腐',
        description: '经典川菜，麻辣鲜香',
        price: 18,
        image: '/images/dish1.jpg'
      },
      {
        id: 2,
        name: '宫保鸡丁',
        description: '酸甜微辣，口感丰富',
        price: 22,
        image: '/images/dish2.jpg'
      }
    ]
  },
  {
    id: 2,
    name: '主食',
    dishes: [
      {
        id: 3,
        name: '白米饭',
        description: '东北优质大米',
        price: 2,
        image: '/images/rice.jpg'
      }
    ]
  }
])

// 购物车数据
const cartItems = ref([])
const cartItemCount = ref(0)
const cartTotal = ref(0)

// 添加到购物车
const addToCart = (dish) => {
  const existingItem = cartItems.value.find(item => item.id === dish.id)
  if (existingItem) {
    existingItem.quantity += 1
  } else {
    cartItems.value.push({
      ...dish,
      quantity: 1
    })
  }
  updateCartSummary()
  showToast('已添加到购物车')
}

// 更新购物车统计
const updateCartSummary = () => {
  cartItemCount.value = cartItems.value.reduce((total, item) => total + item.quantity, 0)
  cartTotal.value = cartItems.value.reduce((total, item) => total + (item.price * item.quantity), 0)
}

// 跳转到购物车
const goToCart = () => {
  router.push('/cart')
}

onMounted(() => {
  // TODO: 根据餐厅ID加载餐厅信息
})
</script>

<style scoped>
.restaurant-detail {
  padding-bottom: 80px;
}

.restaurant-header {
  position: relative;
  height: 200px;
  overflow: hidden;
}

.restaurant-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.restaurant-info {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(transparent, rgba(0, 0, 0, 0.8));
  color: white;
  padding: 20px;
}

.restaurant-info h2 {
  margin: 0 0 8px 0;
  font-size: 24px;
  font-weight: bold;
}

.restaurant-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.rating {
  font-size: 16px;
}

.distance {
  font-size: 14px;
  opacity: 0.8;
}

.restaurant-tags {
  display: flex;
  gap: 6px;
  margin-bottom: 8px;
}

.tag {
  background: rgba(255, 255, 255, 0.2);
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 12px;
}

.delivery-info {
  display: flex;
  justify-content: space-between;
  font-size: 14px;
}

.category-tabs {
  margin-top: 16px;
}

.menu-section {
  padding: 16px;
}

.menu-section h3 {
  margin: 0 0 16px 0;
  font-size: 18px;
  font-weight: bold;
}

.dish-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.dish-card {
  display: flex;
  background: #ffffff;
  border-radius: 8px;
  padding: 12px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.dish-image {
  width: 80px;
  height: 80px;
  border-radius: 8px;
  object-fit: cover;
  margin-right: 12px;
}

.dish-info {
  flex: 1;
}

.dish-info h4 {
  margin: 0 0 4px 0;
  font-size: 16px;
  font-weight: 600;
}

.dish-description {
  margin: 0 0 8px 0;
  font-size: 12px;
  color: #666;
}

.dish-price-action {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.price {
  font-size: 16px;
  font-weight: bold;
  color: #ff6b6b;
}

.cart-float {
  position: fixed;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);
  background: #ff6b6b;
  color: white;
  padding: 12px 24px;
  border-radius: 24px;
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
}

.cart-total {
  font-size: 16px;
  font-weight: bold;
}
</style>