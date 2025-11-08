<template>
  <div class="home">
    <!-- 顶部导航 -->
    <van-nav-bar :title="titleName" left-arrow @click-left="goBack" />

    <!-- 推荐餐厅 -->
    <div class="restaurant-list">
      <div
        v-for="restaurant in restaurants"
        :key="restaurant.id"
        class="restaurant-card"
        @click="goToRestaurant(restaurant.id)"
      >
        <img
          :src="restaurant.image"
          :alt="restaurant.name"
          class="restaurant-image"
        />
        <div class="restaurant-info">
          <h4>{{ restaurant.name }}</h4>
          <div class="restaurant-meta">
            <span class="rating">⭐ {{ restaurant.rating }}</span>
          </div>
          <div class="restaurant-tags">
            <span v-for="tag in restaurant.tags" :key="tag" class="tag">{{
              tag
            }}</span>
          </div>
          <div class="delivery-info">
            <span class="delivery-fee"
              >配送费 ¥{{ restaurant.deliveryFee }}</span
            >
            <span class="delivery-time">{{ restaurant.deliveryTime }}分钟</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { useRouter } from "vue-router";
import { restaurantApi } from "@/api/restaurant";

// 接收路由传递的地址数据
const props = defineProps({
  operation: {
    type: Object,
    default: null,
  },
});

const router = useRouter();

//计算标题,根据传入的props来判断是搜索还是查标签,还是热门餐馆
const titleName = computed(() => {
  let title;
  if (props.operation.tags) {
    title = `标签为${props.operation.tags}的餐厅`;
  } else if (props.operation.keyword) {
    title = `搜索结果为${props.operation.keyword}的餐厅`;
  } else if (props.operation.minRating) {
    title = "热门餐厅";
  }
  return title;
});

const pageInfo = ref({
  page: "",
  limit: "",
});

// 餐厅数据
const restaurants = ref([
  {
    id: 1,
    name: "川味小厨",
    image: "/images/restaurant1.jpg",
    rating: 4.8,
    tags: ["川菜", "麻辣"],
    deliveryFee: 5,
    deliveryTime: 30,
  },
]);

// 返回上一页
const goBack = () => {
  router.back();
};

// 跳转到餐厅详情
const goToRestaurant = (restaurantId) => {
  router.push(`/restaurant/${restaurantId}`)
}

//加载热门餐厅
const loadResaurants = async (operation) => {
  try {
    const result = await restaurantApi.getRestaurantList(operation);

    //把图片都加上nerURL
    restaurants.value = result.data.map((item) => {
      item.image = new URL(item.image, import.meta.url).href;
      return item;
    });
  } catch (error) {
    showToast(error.message || "加载热门餐厅查询失败，请重试");
  }
};

onMounted(() => {
  const {page,limit,...operates} = props.operation;
  
  const reOpention = {
    page: Number(page),
    limit: Number(limit),
  };

  console.log('我要看看这是啥',props.operation);
  console.log('我要看看这是1',props.operation.tags);
  
  if (props.operation.tags) {
    reOpention.tags = props.operation.tags;
    console.log(1);
    
  } else if (props.operation.keyword) {
    reOpention.keyword = props.operation.keyword;
    console.log(2);
  } else if (props.operation.minRating) {
    reOpention.minRating = props.operation.minRating
    console.log(3);
  }

  console.log("我来看看参数", reOpention);

  // 根据不同的搜索选项来显示餐厅列表
  loadResaurants(reOpention);

  // 将props数据中关于页码的信息复制到页码对象
  Object.assign(pageInfo.value, {
    page: reOpention.page,
    limit: reOpention.limit,
  });
});
</script>

<style scoped>
.home {
  padding-bottom: 50px;
}

.restaurant-list {
  margin-top: 10px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.restaurant-card {
  display: flex;
  background: #ffffff;
  margin-left: 10px;
  margin-right: 10px;
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
