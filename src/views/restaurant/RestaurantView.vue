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
          @click="scrollToCategory(category.id)"
        >
          {{ category.name }}
        </div>
      </div>

      <!-- 右侧菜品列表 -->
      <div class="dish-content" ref="dishContent" @scroll="handleScroll">
        <div
          v-for="category in dishCategories"
          :key="category.id"
          class="category-section"
          :id="'category-' + category.id"
          ref="categorySections"
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
        <van-icon name="cart-o" :badge="currentRestaurantTotalQuantity" />
      </div>
      <div class="cart-info">
        <div class="cart-total">¥{{ currentRestaurantTotalPrice }}</div>
        <div class="cart-delivery-fee">
          配送费 ¥{{ restaurant.deliveryFee }}
        </div>
      </div>
      <div class="checkout-btn" :class="{ disabled: currentRestaurantTotalQuantity === 0 }">
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
import { ref, computed, onMounted, onUnmounted, nextTick, watch, reactive } from "vue";
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

// 滚动相关的引用
const dishContent = ref(null);
const categorySections = ref([]);
const categoryOffsets = ref([]);

// 滚动状态管理
const scrollState = reactive({
  isScrolling: false,
  currentScrollTop: 0,
});

// 滚动节流处理
let scrollTimer = null;
const THROTTLE_DELAY = 16; // 约60fps

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


//getting餐厅数据接口
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
      {
        id: 5,
        name: "水煮鱼",
        description: "麻辣鲜香，鱼肉嫩滑",
        price: 58,
        image: "/images/dish5.jpg",
        quantity: 0,
        categoryId: 1,
      },
    ],
  },
  {
    id: 2,
    name: "凉菜",
    dishes: [
      {
        id: 6,
        name: "凉拌黄瓜",
        description: "清爽开胃，酸甜可口",
        price: 12,
        image: "/images/dish6.jpg",
        quantity: 0,
        categoryId: 2,
      },
      {
        id: 7,
        name: "口水鸡",
        description: "麻辣鲜香，口感丰富",
        price: 28,
        image: "/images/dish7.jpg",
        quantity: 0,
        categoryId: 2,
      },
    ],
  },
  {
    id: 3,
    name: "汤品",
    dishes: [
      {
        id: 3,
        name: "番茄鸡蛋汤",
        description: "酸甜开胃，营养丰富",
        price: 18,
        image: "/images/dish3.jpg",
        quantity: 0,
        categoryId: 3,
      },
      {
        id: 8,
        name: "冬瓜排骨汤",
        description: "清淡营养，排骨鲜嫩",
        price: 32,
        image: "/images/dish8.jpg",
        quantity: 0,
        categoryId: 3,
      },
    ],
  },
  {
    id: 4,
    name: "主食",
    dishes: [
      {
        id: 4,
        name: "蛋炒饭",
        description: "粒粒分明，香气扑鼻",
        price: 15,
        image: "/images/dish4.jpg",
        quantity: 0,
        categoryId: 4,
      },
      {
        id: 9,
        name: "牛肉面",
        description: "汤头浓郁，牛肉鲜嫩",
        price: 25,
        image: "/images/dish9.jpg",
        quantity: 0,
        categoryId: 4,
      },
    ],
  },
  {
    id: 5,
    name: "饮料",
    dishes: [
      {
        id: 10,
        name: "酸梅汤",
        description: "酸甜解腻，生津止渴",
        price: 8,
        image: "/images/dish10.jpg",
        quantity: 0,
        categoryId: 5,
      },
      {
        id: 11,
        name: "可乐",
        description: "经典碳酸饮料",
        price: 6,
        image: "/images/dish11.jpg",
        quantity: 0,
        categoryId: 5,
      },
    ],
  },
]);

//获取菜品和分类信息接口
const loadDishCategories = async (id) => {
  try {
    const result = await restaurantApi.getRestaurantCategories({ id });

    console.log('API返回的数据结构:', result);

    //把图片都加上nerURL
    result.data.image = new URL(result.data.image, import.meta.url).href;
    //把图片都加上nerURL
    dishCategories.value = result.data.categories.map((item) => {
      item.dishes = item.dishes.map((itemItem) => {
        // 直接使用接口返回的路径，因为路径是正确的
        itemItem.image = new URL(itemItem.image, import.meta.url).href;

        // 根据购物车中的实际数量设置菜品数量，而不是重置为0
        const cartItem = cartStore.items.find(cartItem => cartItem.id === itemItem.id);
        itemItem.quantity = cartItem ? cartItem.quantity : 0;

        return itemItem;
      });

      return item;
    });

    console.log('处理后的菜品分类数据:', dishCategories.value);

    // 数据加载完成后重新初始化分类偏移量
    await nextTick();
    // 使用多次延迟确保DOM完全渲染和计算完成
    setTimeout(() => {
      initCategoryOffsets();

      // 再次延迟以确保样式应用完成
      setTimeout(() => {
        if (dishContent.value) {

          // 如果内容高度仍然不足，强制触发重新计算
          if (dishContent.value.scrollHeight <= dishContent.value.clientHeight) {
            // 强制重新布局
            dishContent.value.style.height = 'auto';
            setTimeout(() => {
              dishContent.value.style.height = '';
              initCategoryOffsets();
            }, 50);
          }
        }
      }, 100);
    }, 100); // 延迟一点时间确保DOM完全更新
  } catch (error) {
    showToast(error.message || "加载菜品分类查询失败，请重试");
    console.error('加载菜品分类失败:', error);
  }
};

// 购物车数据 - 使用全局 store
const cartItems = computed(() => cartStore.items);
const totalQuantity = computed(() => cartStore.totalCount);
const totalPrice = computed(() => cartStore.totalPrice);

// 当前餐厅的购物车数据
const currentRestaurantCartItems = computed(() =>
  cartStore.items.filter(item => item.restaurantId === restaurant.value.id)
);
const currentRestaurantTotalQuantity = computed(() =>
  currentRestaurantCartItems.value.reduce((sum, item) => sum + item.quantity, 0)
);
const currentRestaurantTotalPrice = computed(() =>
  currentRestaurantCartItems.value.reduce((sum, item) => sum + item.price * item.quantity, 0)
);

// 检查是否有跨餐厅商品
const hasCrossRestaurantItems = computed(() =>
  cartStore.items.some(item => item.restaurantId !== restaurant.value.id)
);


// 监听购物车变化，同步更新商品页面的数量
watch(cartItems, (newCartItems) => {
  // 只处理当前餐厅的商品
  const currentRestaurantItems = newCartItems.filter(item =>
    item.restaurantId === restaurant.value.id
  );

  dishCategories.value.forEach(category => {
    category.dishes.forEach(dish => {
      const cartItem = currentRestaurantItems.find(item => item.id === dish.id);
      if (cartItem) {
        dish.quantity = cartItem.quantity;
      } else {
        dish.quantity = 0;
      }
    });
  });
}, { deep: true });

// 显示菜品详情
const showDishDetail = (dish) => {
  selectedDish.value = dish;
  showDishPopup.value = true;
};


// 同步更新所有菜品数量的工具函数
const syncAllDishQuantities = () => {
  const currentRestaurantItems = cartStore.items.filter(item =>
    item.restaurantId === restaurant.value.id
  );

  dishCategories.value.forEach(category => {
    category.dishes.forEach(dish => {
      const cartItem = currentRestaurantItems.find(item => item.id === dish.id);
      if (cartItem) {
        dish.quantity = cartItem.quantity;
      } else {
        dish.quantity = 0;
      }
    });
  });
};

// 添加到购物车
const addToCart = (dish) => {
  const product = {
    id: dish.id,
    name: dish.name,
    price: dish.price,
    image: dish.image,
    description: dish.description,
    restaurantId: restaurant.value.id,
    restaurantName: restaurant.value.name,
    categoryId: dish.categoryId
  };

  // 直接添加商品，购物车操作限制在单个店铺内
  cartStore.addItem(product);

  // 强制同步所有菜品数量
  nextTick(() => {
    syncAllDishQuantities();
  });
};

// 从购物车移除
const removeFromCart = (dish) => {
  const cartItem = cartStore.items.find(item => item.id === dish.id);
  if (cartItem && cartItem.quantity > 1) {
    // 更新购物车中的数量
    cartStore.updateQuantity(dish.id, cartItem.quantity - 1);
  } else if (cartItem) {
    // 移除商品
    cartStore.removeItem(dish.id);
  }

  // 强制同步所有菜品数量
  nextTick(() => {
    syncAllDishQuantities();
  });
};

// 删除菜品
const deleteItem = (dish) => {
  const cartItem = cartStore.items.find(item => item.id === dish.id);
  if (cartItem) {
    cartStore.removeItem(dish.id);
  }

  // 强制同步所有菜品数量
  nextTick(() => {
    syncAllDishQuantities();
  });
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

// 查找分类区域的工具函数
const findCategorySection = (categoryId) => {
  return categorySections.value.find(section =>
    section.id === `category-${categoryId}`
  );
};

// 滚动到指定分类
const scrollToCategory = (categoryId) => {
  activeCategory.value = categoryId;

  // 使用Vue的ref替代getElementById
  const targetSection = findCategorySection(categoryId);

  if (targetSection && dishContent.value) {
    // 直接使用DOM元素的scrollIntoView方法
    targetSection.scrollIntoView({
      behavior: 'smooth',
      block: 'start'
    });
  }
};

// 节流处理的滚动事件
const handleScroll = () => {
  if (scrollTimer) return;

  // 更新滚动状态
  scrollState.isScrolling = true;
  scrollState.currentScrollTop = dishContent.value?.scrollTop || 0;

  scrollTimer = setTimeout(() => {
    scrollTimer = null;
    scrollState.isScrolling = false;
    performScrollCheck();
  }, THROTTLE_DELAY);
};

// 执行实际的滚动检查逻辑
const performScrollCheck = () => {
  if (!dishContent.value || !categorySections.value?.length) return;

  // 使用缓存的滚动位置，避免重复的DOM查询
  const scrollTop = scrollState.currentScrollTop;

  // 使用预计算的偏移量来提高性能
  for (let i = 0; i < categoryOffsets.value.length; i++) {
    const offsetData = categoryOffsets.value[i];
    const section = categorySections.value[i];

    if (!section) continue;

    const sectionHeight = section.offsetHeight;

    // 如果当前滚动位置在某个分类区间内
    if (scrollTop >= offsetData.offsetTop - 100 &&
        scrollTop < offsetData.offsetTop + sectionHeight - 100) {

      if (activeCategory.value !== offsetData.id) {
        activeCategory.value = offsetData.id;
      }
      break;
    }
  }
};

// 初始化分类偏移量
const initCategoryOffsets = () => {
  nextTick(() => {
    // 确保 categorySections 是一个数组且有元素
    if (Array.isArray(categorySections.value) && categorySections.value.length > 0) {
      console.log('初始化分类偏移量, 分类数量:', categorySections.value.length);
      categoryOffsets.value = categorySections.value.map(section => {
        const id = parseInt(section.id.replace('category-', ''));
        const offsetTop = section.offsetTop;
        console.log(`分类 ${id}, offsetTop:`, offsetTop);
        return { id, offsetTop };
      });
      console.log('分类偏移量初始化完成:', categoryOffsets.value);
    } else {
      console.warn('categorySections.value 不是一个有效的数组:', categorySections.value);
    }
  });
};

// 格式化距离
const formatDistance = (distance) => {
  return distance < 1 ? `${Math.round(distance * 1000)}m` : `${distance}km`;
};

// 组件卸载时清理定时器
onUnmounted(() => {
  if (scrollTimer) {
    clearTimeout(scrollTimer);
    scrollTimer = null;
  }
});

onMounted(() => {
  const id = props.id;

  // 调试购物车store方法
  console.log('购物车store方法检查:');
  console.log('items:', cartStore.items);
  console.log('addItem方法:', typeof cartStore.addItem);
  console.log('clearCart方法:', typeof cartStore.clearCart);
  console.log('updateQuantity方法:', typeof cartStore.updateQuantity);
  console.log('removeItem方法:', typeof cartStore.removeItem);

  // 先初始化默认数据（用于测试滚动功能）
  console.log('使用默认数据进行初始化');
  nextTick(() => {
    initCategoryOffsets();
    console.log('默认数据初始化完成');
  });

  //根据餐厅ID加载餐厅数据
  loadResaurant(id);
  //加载菜品数据
  loadDishCategories(id);
});
</script>

<style scoped>
.restaurant-view {
  height: 100vh;
  background: #f5f5f5;
  display: flex;
  flex-direction: column;
  overflow: hidden;
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
  min-height: 0; /* 确保flex子项可以缩小 */
}

.category-sidebar {
  width: 80px;
  background: #f8f8f8;
  overflow-y: auto;
  flex-shrink: 0;
}

.category-item {
  padding: 16px 8px;
  text-align: center;
  font-size: 14px;
  cursor: pointer;
  border-bottom: 1px solid #eee;
  transition: all 0.3s ease;
  position: relative;
}

.category-item.active {
  background: white;
  color: #ff6b6b;
  font-weight: bold;
}

.category-item.active::before {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 3px;
  height: 16px;
  background: #ff6b6b;
  border-radius: 2px;
}

.dish-content {
  flex: 1;
  overflow-y: auto;
  background: white;
  scroll-behavior: smooth;
  min-height: 0; /* 确保内容可以滚动 */
}

.category-section {
  padding: 16px;
  min-height: 200px; /* 确保每个分类有足够的最小高度 */
}

.category-section:last-child {
  padding-bottom: 32px; /* 为最后一个分类添加额外的底部内边距 */
  min-height: 300px; /* 最后一个分类需要更多空间 */
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
