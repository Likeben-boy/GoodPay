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
    component: () => import('@/views/restaurant/RestaurantView.vue'),
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
    path: '/order/checkout',
    name: 'OrderCheckout',
    component: () => import('@/views/order/OrderCheckout.vue'),
    meta: {
      title: '订单结算',
      requireAuth: true
    }
  },
  {
    path: '/order/success',
    name: 'OrderSuccess',
    component: () => import('@/views/order/OrderSuccess.vue'),
    meta: {
      title: '订单成功',
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
    path: '/user/address',
    name: 'AddressList',
    component: () => import('@/views/user/AddressList.vue'),
    meta: {
      title: '收货地址',
      requireAuth: true
    }
  },
  {
    path: '/user/address/add',
    name: 'AddressAdd',
    component: () => import('@/views/user/AddressEdit.vue'),
    meta: {
      title: '添加地址',
      requireAuth: true
    }
  },
  {
    path: '/user/address/edit/:id',
    name: 'AddressEdit',
    component: () => import('@/views/user/AddressEdit.vue'),
    meta: {
      title: '编辑地址',
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