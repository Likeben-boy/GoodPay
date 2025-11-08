<template>
  <div class="restaurant-view">
    <!-- 顶部导航 -->
    <van-nav-bar :title="restaurant.name" left-arrow @click-left="goBack" />

    <!-- 餐厅信息头部 -->
    <div class="restaurant-header">
      <div class="restaurant-image">
        <img :src="restaurant.image" :alt="restaurant.name" />
      </div>
      <div class="restaurant-info">
        <h2>{{ restaurant.name }}</h2>
        <div class="restaurant-meta">
          <span class="rating">⭐ {{ restaurant.rating }}</span>
        </div>
        <div class="restaurant-tags">
          <span v-for="tag in restaurant.tags" :key="tag" class="tag">{{
            tag
          }}</span>
        </div>
        <div class="delivery-info">
          <span class="delivery-fee">配送费 ¥{{ restaurant.deliveryFee }}</span>
          <span class="delivery-time">{{ restaurant.deliveryTime }}分钟</span>
        </div>
      </div>
    </div>

    <!-- 菜品区域 -->
    <div class="menu-container">
      <!-- 左侧分类导航 -->
      <div class="category-sidebar">
        <div
          v-for="category in dishCategories"
          :key="category.id"
          class="category-item"
          :class="{ active: activeCategory === category.id }"
          @click="activeCategory = category.id"
        >
          {{ category.name }}
        </div>
      </div>

      <!-- 右侧菜品列表 -->
      <div class="dish-content">
        <div
          v-for="category in dishCategories"
          :key="category.id"
          class="category-section"
        >
          <h3 class="category-title">{{ category.name }}</h3>
          <div class="dish-list">
            <div
              v-for="dish in category.dishes"
              :key="dish.id"
              class="dish-item"
              @click="showDishDetail(dish)"
            >
              <img :src="dish.image" :alt="dish.name" class="dish-image" />
              <div class="dish-info">
                <h4>{{ dish.name }}</h4>
                <p class="dish-desc">{{ dish.description }}</p>
                <div class="dish-price-actions" @click.stop>
                  <span class="price">¥{{ dish.price }}</span>
                  <van-stepper
                    v-model="dish.quantity"
                    min="0"
                    theme="round"
                    button-size="22"
                    disable-input
                    @plus="addToCart(dish)"
                    @minus="removeFromCart(dish)"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 购物车固定栏 -->
    <div class="cart-bar" @click="showCart = true">
      <div class="cart-icon">
        <van-icon name="cart-o" :badge="totalQuantity" />
      </div>
      <div class="cart-info">
        <div class="cart-total">¥{{ totalPrice }}</div>
        <div class="cart-delivery-fee">
          配送费 ¥{{ restaurant.deliveryFee }}
        </div>
      </div>
      <div class="checkout-btn" :class="{ disabled: totalQuantity === 0 }">
        去结算
      </div>
    </div>

    <!-- 购物车弹窗 -->
    <van-popup
      v-model:show="showCart"
      position="bottom"
      :style="{ height: '70%' }"
      round
    >
      <CartPopup
        :cart-items="cartItems"
        :delivery-fee="restaurant.deliveryFee"
        :restaurant-id="restaurant.id"
        @add-item="addToCart"
        @remove-item="removeFromCart"
        @delete-item="deleteItem"
        @checkout="goToCheckout"
        @update:show="showCart = $event"
      />
    </van-popup>

    <!-- 菜品详情弹窗 -->
    <van-popup
      v-model:show="showDishPopup"
      position="bottom"
      :style="{ height: '80%' }"
      round
    >
      <DishDetail
        :dish="selectedDish"
        @add-to-cart="addToCart"
        @close="showDishPopup = false"
      />
    </van-popup>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { useRouter } from "vue-router";
import CartPopup from "@/components/CartPopup.vue";
import DishDetail from "@/components/DishDetail.vue";
import { restaurantApi } from "@/api";
import { useCartStore } from "@/store/cart";
import { showToast } from 'vant';

const props = defineProps({
  id: String,
});
const router = useRouter();

// 初始化购物车 store
const cartStore = useCartStore();

const activeCategory = ref(1);
const showCart = ref(false);
const showDishPopup = ref(false);
const selectedDish = ref(null);

// 餐厅数据
const restaurant = ref({
  id: 1,
  name: "川味小厨",
  image: "/images/restaurant1.jpg",
  rating: 4.8,
  tags: ["川菜", "麻辣"],
  deliveryFee: 5,
  deliveryTime: 30,
});

//获取餐厅数据接口
const loadResaurant = async (id) => {
  try {
    const result = await restaurantApi.getRestaurantDetail({ id });

    //把图片都加上nerURL
    result.data.image = new URL(result.data.image, import.meta.url).href;
    restaurant.value = result.data;
  } catch (error) {
    showToast(error.message || "加载餐厅查询失败，请重试");
  }
};

// 菜品分类和菜品数据
const dishCategories = ref([
  {
    id: 1,
    name: "热销菜品",
    dishes: [
      {
        id: 1,
        name: "麻婆豆腐",
        description: "经典川菜，麻辣鲜香",
        price: 28,
        image: "/images/dish1.jpg",
        quantity: 0,
        categoryId: 1,
      },
      {
        id: 2,
        name: "宫保鸡丁",
        description: "鸡肉鲜嫩，花生香脆",
        price: 32,
        image: "/images/dish2.jpg",
        quantity: 0,
        categoryId: 1,
      },
    ],
  },
  {
    id: 2,
    name: "汤品",
    dishes: [
      {
        id: 3,
        name: "番茄鸡蛋汤",
        description: "酸甜开胃，营养丰富",
        price: 18,
        image: "/images/dish3.jpg",
        quantity: 0,
        categoryId: 2,
      },
    ],
  },
  {
    id: 3,
    name: "主食",
    dishes: [
      {
        id: 4,
        name: "蛋炒饭",
        description: "粒粒分明，香气扑鼻",
        price: 15,
        image: "/images/dish4.jpg",
        quantity: 0,
        categoryId: 3,
      },
    ],
  },
]);

//获取菜品和分类信息接口
const loadDishCategories = async (id) => {
  try {
    const result = await restaurantApi.getRestaurantCategories({ id });

    //把图片都加上nerURL
    result.data.image = new URL(result.data.image, import.meta.url).href;
    //把图片都加上nerURL
    dishCategories.value = result.data.categories.map((item) => {      
      item.dishes = item.dishes.map((itemItem) => {
        // 直接使用接口返回的路径，因为路径是正确的
        itemItem.image = new URL(itemItem.image, import.meta.url).href;
        itemItem.quantity = 0;
        return itemItem;
      });
      return item;
    });
  } catch (error) {
    showToast(error.message || "加载菜品分类查询失败，请重试");
  }
};

// 购物车数据 - 使用全局 store
const cartItems = computed(() => cartStore.items);
const totalQuantity = computed(() => cartStore.totalCount);
const totalPrice = computed(() => cartStore.totalPrice);

// 显示菜品详情
const showDishDetail = (dish) => {
  selectedDish.value = dish;
  showDishPopup.value = true;
};

// 添加到购物车
const addToCart = (dish) => {
  cartStore.addItem({
    id: dish.id,
    name: dish.name,
    price: dish.price,
    image: dish.image,
    description: dish.description,
    restaurantId: restaurant.value.id,
    restaurantName: restaurant.value.name,
    categoryId: dish.categoryId
  });
};

// 从购物车移除
const removeFromCart = (dish) => {
  const cartItem = cartStore.items.find(item => item.id === dish.id);
  if (cartItem && cartItem.quantity > 1) {
    cartStore.updateQuantity(dish.id, cartItem.quantity - 1);
  } else {
    cartStore.removeItem(dish.id);
  }
};

// 删除菜品
const deleteItem = (dish) => {
  cartStore.removeItem(dish.id);
};

// 跳转到结算页面
const goToCheckout = () => {
  showCart.value = false;
  // 可以通过路由参数传递餐厅ID，结算页面可以从全局store获取购物车数据
  router.push({
    path: "/order/checkout",
    query: {
      restaurantId: restaurant.value.id,
      restaurantName: restaurant.value.name,
      deliveryFee: restaurant.value.deliveryFee
    }
  });
};

// 返回上一页
const goBack = () => {
  router.back();
};

// 格式化距离
const formatDistance = (distance) => {
  return distance < 1 ? `${Math.round(distance * 1000)}m` : `${distance}km`;
};

onMounted(() => {
  const id = props.id;
  //根据餐厅ID加载餐厅数据
  loadResaurant(id);
  //加载菜品数据
  loadDishCategories(id);
  console.log('1111');
  
});
</script>

<style scoped>
.restaurant-view {
  height: 100vh;
  background: #f5f5f5;
  display: flex;
  flex-direction: column;
}

.restaurant-header {
  background: white;
  padding: 16px;
  display: flex;
  gap: 16px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.restaurant-image img {
  width: 80px;
  height: 80px;
  border-radius: 8px;
  object-fit: cover;
}

.restaurant-info {
  flex: 1;
}

.restaurant-info h2 {
  margin: 0 0 8px 0;
  font-size: 20px;
  font-weight: bold;
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

.menu-container {
  flex: 1;
  display: flex;
  overflow: hidden;
}

.category-sidebar {
  width: 80px;
  background: #f8f8f8;
  overflow-y: auto;
}

.category-item {
  padding: 16px 8px;
  text-align: center;
  font-size: 14px;
  cursor: pointer;
  border-bottom: 1px solid #eee;
}

.category-item.active {
  background: white;
  color: #ff6b6b;
  font-weight: bold;
}

.dish-content {
  flex: 1;
  overflow-y: auto;
  background: white;
}

.category-section {
  padding: 16px;
}

.category-title {
  font-size: 16px;
  font-weight: bold;
  margin-bottom: 16px;
}

.dish-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.dish-item {
  display: flex;
  gap: 12px;
  cursor: pointer;
}

.dish-image {
  width: 80px;
  height: 80px;
  border-radius: 8px;
  object-fit: cover;
}

.dish-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.dish-info h4 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
}

.dish-desc {
  font-size: 12px;
  color: #666;
  margin: 4px 0;
}

.dish-price-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.price {
  color: #ff6b6b;
  font-size: 16px;
  font-weight: bold;
}

.cart-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: white;
  display: flex;
  align-items: center;
  padding: 12px 16px;
  box-shadow: 0 -2px 8px rgba(0, 0, 0, 0.1);
  z-index: 100;
}

.cart-icon {
  margin-right: 12px;
  font-size: 24px;
}

.cart-info {
  flex: 1;
  margin-right: 12px;
}

.cart-total {
  font-size: 18px;
  font-weight: bold;
  color: #ff6b6b;
}

.cart-delivery-fee {
  font-size: 12px;
  color: #666;
}

.checkout-btn {
  background: #ff6b6b;
  color: white;
  padding: 8px 24px;
  border-radius: 20px;
  font-weight: bold;
  cursor: pointer;
}

.checkout-btn.disabled {
  background: #ccc;
  cursor: not-allowed;
}
</style>
