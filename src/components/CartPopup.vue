<template>
  <div class="cart-popup">
    <div class="cart-header">
      <h3>购物车</h3>
      <div class="cart-actions">
        <span class="clear-cart" @click="clearCart">清空购物车</span>
        <div class="close-btn" @click="$emit('update:show', false)">
          <van-icon name="cross" />
        </div>
      </div>
    </div>

    <div class="cart-content">
      <div v-if="cartItems.length === 0" class="empty-cart">
        <van-icon name="cart-o" size="48" color="#ddd" />
        <p>购物车是空的</p>
      </div>

      <div v-else class="cart-items">
        <div v-for="item in cartItems" :key="item.id" class="cart-item">
          <img :src="item.image" :alt="item.name" class="item-image" />
          <div class="item-info">
            <h4>{{ item.name }}</h4>
            <p class="item-spec" v-if="item.selectedSpec">{{ item.selectedSpec }}</p>
            <div class="item-price">
              <span class="price">¥{{ item.price }}</span>
              <div class="item-actions">
                <van-stepper
                  v-model="item.quantity"
                  min="0"
                  theme="round"
                  button-size="22"
                  disable-input
                  @plus="$emit('add-item', item)"
                  @minus="$emit('remove-item', item)"
                />
                <div class="delete-btn" @click="$emit('delete-item', item)">
                  <van-icon name="delete-o" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="cart-footer">
      <div class="price-summary">
        <div class="subtotal">
          <span>商品总价</span>
          <span>¥{{ subtotal }}</span>
        </div>
        <div class="delivery-fee">
          <span>配送费</span>
          <span>¥{{ deliveryFee }}</span>
        </div>
        <div class="total">
          <span>合计</span>
          <span class="total-price">¥{{ total }}</span>
        </div>
      </div>
      <div
        class="checkout-btn"
        :class="{ disabled: cartItems.length === 0 }"
        @click="cartItems.length > 0 && $emit('checkout')"
      >
        去结算 ({{ totalQuantity }}件)
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  cartItems: {
    type: Array,
    required: true
  },
  deliveryFee: {
    type: Number,
    default: 0
  }
})

const emit = defineEmits(['add-item', 'remove-item', 'delete-item', 'checkout'])

const subtotal = computed(() => {
  return props.cartItems.reduce((total, item) => total + item.price * item.quantity, 0)
})

const total = computed(() => {
  return subtotal.value + props.deliveryFee
})

const totalQuantity = computed(() => {
  return props.cartItems.reduce((total, item) => total + item.quantity, 0)
})

const clearCart = () => {
  if (confirm('确定要清空购物车吗？')) {
    props.cartItems.forEach(item => emit('delete-item', item))
  }
}
</script>

<style scoped>
.cart-popup {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.cart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border-bottom: 1px solid #eee;
}

.cart-header h3 {
  margin: 0;
  font-size: 18px;
  font-weight: bold;
}

.cart-actions {
  display: flex;
  align-items: center;
  gap: 16px;
}

.clear-cart {
  color: #ff6b6b;
  font-size: 14px;
  cursor: pointer;
}

.close-btn {
  cursor: pointer;
  color: #666;
}

.cart-content {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
}

.empty-cart {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 200px;
  color: #ddd;
}

.empty-cart p {
  margin-top: 8px;
  font-size: 14px;
}

.cart-items {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.cart-item {
  display: flex;
  gap: 12px;
  background: #f9f9f9;
  border-radius: 8px;
  padding: 12px;
}

.item-image {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  object-fit: cover;
}

.item-info {
  flex: 1;
}

.item-info h4 {
  margin: 0 0 4px 0;
  font-size: 16px;
  font-weight: 600;
}

.item-spec {
  color: #666;
  font-size: 12px;
  margin-bottom: 8px;
}

.item-price {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.price {
  color: #ff6b6b;
  font-size: 16px;
  font-weight: bold;
}

.item-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

.delete-btn {
  color: #ff6b6b;
  cursor: pointer;
  padding: 4px;
}

.cart-footer {
  background: white;
  border-top: 1px solid #eee;
  padding: 16px;
}

.price-summary {
  margin-bottom: 16px;
}

.subtotal,
.delivery-fee {
  display: flex;
  justify-content: space-between;
  font-size: 14px;
  color: #666;
  margin-bottom: 4px;
}

.total {
  display: flex;
  justify-content: space-between;
  font-size: 16px;
  font-weight: bold;
  margin-bottom: 16px;
}

.total-price {
  color: #ff6b6b;
  font-size: 20px;
}

.checkout-btn {
  background: #ff6b6b;
  color: white;
  padding: 12px;
  text-align: center;
  border-radius: 8px;
  font-weight: bold;
  cursor: pointer;
}

.checkout-btn.disabled {
  background: #ccc;
  cursor: not-allowed;
}

.checkout-btn:not(.disabled):hover {
  background: #ff5252;
}
</style>