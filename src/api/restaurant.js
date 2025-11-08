import { request } from '@/utils/request'

export const restaurantApi = {
  // 获取餐厅列表
  getRestaurantList: (params) => request.get('/restaurants', params),

  //获取标签页面
  getRestaurantTag: (params) => request.get('/restaurants/tags',params),

  // 获取餐厅详情
  getRestaurantDetail: (id) => request.get('/restaurants/id',id),

  // 获取餐厅菜品分类
  getRestaurantCategories: (id) => request.get('/restaurants/menu',id),

  // 获取餐厅菜品列表
  getRestaurantDishes: (restaurantId, params) => request.get(`/restaurants/${restaurantId}/dishes`, params),

  // 获取餐厅评价列表
  getRestaurantReviews: (restaurantId, params) => request.get(`/restaurants/${restaurantId}/reviews`, params),

  // 提交餐厅评价
  submitReview: (restaurantId, data) => request.post(`/restaurants/${restaurantId}/reviews`, data)
}