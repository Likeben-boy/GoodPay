import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useCartStore = defineStore('cart', () => {
  const items = ref(JSON.parse(localStorage.getItem('cart') || '[]'))

  const totalCount = computed(() => items.value.reduce((sum, item) => sum + item.quantity, 0))
  const totalPrice = computed(() => items.value.reduce((sum, item) => sum + item.price * item.quantity, 0))

  // 添加商品到购物车
  const addItem = (product) => {
    const existingItem = items.value.find(item => item.id === product.id)

    if (existingItem) {
      existingItem.quantity += product.quantity || 1
    } else {
      items.value.push({
        ...product,
        quantity: product.quantity || 1
      })
    }

    saveToLocalStorage()
  }

  
  // 更新商品数量
  const updateQuantity = (productId, quantity) => {
    const item = items.value.find(item => item.id === productId)
    if (item) {
      if (quantity > 0) {
        item.quantity = quantity
      } else {
        removeItem(productId)
      }
      saveToLocalStorage()
    }
  }

  // 移除商品
  const removeItem = (productId) => {
    items.value = items.value.filter(item => item.id !== productId)
    saveToLocalStorage()
  }

  // 清空指定餐厅的商品
  const clearRestaurantItems = (restaurantId) => {
    items.value = items.value.filter(item => item.restaurantId !== restaurantId)
    saveToLocalStorage()
  }

  // 清空购物车
  const clearCart = () => {
    items.value = []
    saveToLocalStorage()
  }

  // 检查是否包含指定餐厅的商品
  const hasRestaurantItems = (restaurantId) => {
    return items.value.some(item => item.restaurantId === restaurantId)
  }

  // 检查是否包含其他餐厅的商品
  const hasOtherRestaurantItems = (restaurantId) => {
    return items.value.some(item => item.restaurantId !== restaurantId)
  }

  // 获取指定餐厅的商品
  const getRestaurantItems = (restaurantId) => {
    return items.value.filter(item => item.restaurantId === restaurantId)
  }

  // 保存到本地存储
  const saveToLocalStorage = () => {
    localStorage.setItem('cart', JSON.stringify(items.value))
  }

  return {
    items,
    totalCount,
    totalPrice,
    addItem,
    updateQuantity,
    removeItem,
    clearRestaurantItems,
    clearCart,
    hasRestaurantItems,
    hasOtherRestaurantItems,
    getRestaurantItems
  }
})