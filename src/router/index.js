import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    name: 'HomeView',
    component: () => import('@/views/home/HomeView.vue'),
    meta: {
      title: '首页',
      keepAlive: true
    }
  },
  {
    path: '/restaurant/:id',
    name: 'RestaurantDetail',
    component: () => import('@/views/restaurant/Detail.vue'),
    meta: {
      title: '餐厅详情'
    }
  },
  {
    path: '/order',
    name: 'OrderList',
    component: () => import('@/views/order/List.vue'),
    meta: {
      title: '我的订单',
      requireAuth: true
    }
  },
  {
    path: '/order/:id',
    name: 'OrderDetail',
    component: () => import('@/views/order/Detail.vue'),
    meta: {
      title: '订单详情',
      requireAuth: true
    }
  },
  {
    path: '/cart',
    name: 'Cart',
    component: () => import('@/views/order/Cart.vue'),
    meta: {
      title: '购物车',
      requireAuth: true
    }
  },
  {
    path: '/user',
    name: 'UserProfile',
    component: () => import('@/views/user/Profile.vue'),
    meta: {
      title: '个人中心',
      requireAuth: true
    }
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/user/Login.vue'),
    meta: {
      title: '登录'
    }
  },
  {
    path: '/payment/:orderId',
    name: 'Payment',
    component: () => import('@/views/order/Payment.vue'),
    meta: {
      title: '支付',
      requireAuth: true
    }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  // 设置页面标题
  if (to.meta.title) {
    document.title = `${to.meta.title} - GoodPay`
  }

  // TODO 权限验证 等待后段接口
  // if (to.meta.requireAuth) {
  //   const token = localStorage.getItem('token')
  //   if (!token) {
  //     next('/login')
  //   } else {
  //     next()
  //   }
  // } else {
  //   next()
  // }
  next();
})

export default router