<template>
  <div class="dish-detail">
    <div class="dish-header">
      <img :src="dish.image" :alt="dish.name" class="dish-image" />
      <div class="close-btn" @click="$emit('close')">
        <van-icon name="cross" />
      </div>
    </div>

    <div class="dish-content">
      <h2>{{ dish.name }}</h2>
      <p class="dish-desc">{{ dish.description }}</p>

      <div class="dish-price">
        <span class="price">¥{{ dish.price }}</span>
        <span class="original-price" v-if="dish.originalPrice">¥{{ dish.originalPrice }}</span>
      </div>

      <div class="dish-specs" v-if="dish.specs && dish.specs.length > 0">
        <h3>规格</h3>
        <div class="spec-options">
          <div
            v-for="spec in dish.specs"
            :key="spec.name"
            class="spec-item"
            :class="{ active: selectedSpec === spec.name }"
            @click="selectedSpec = spec.name"
          >
            {{ spec.name }}
            <span class="spec-price">+¥{{ spec.price }}</span>
          </div>
        </div>
      </div>

      <div class="dish-ingredients" v-if="dish.ingredients && dish.ingredients.length > 0">
        <h3>配料</h3>
        <div class="ingredient-list">
          <span v-for="ingredient in dish.ingredients" :key="ingredient" class="ingredient">
            {{ ingredient }}
          </span>
        </div>
      </div>

      <div class="dish-actions">
        <div class="quantity-control">
          <van-stepper
            v-model="quantity"
            min="1"
            max="99"
            theme="round"
            button-size="22"
          />
        </div>
        <div class="add-to-cart-btn" @click="addToCart">
          加入购物车
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  dish: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['add-to-cart', 'close'])

const quantity = ref(1)
const selectedSpec = ref('')

const finalPrice = computed(() => {
  let price = props.dish.price
  if (selectedSpec.value) {
    const spec = props.dish.specs?.find(s => s.name === selectedSpec.value)
    if (spec) {
      price += spec.price
    }
  }
  return price * quantity.value
})

const addToCart = () => {
  const cartItem = {
    ...props.dish,
    quantity: quantity.value,
    selectedSpec: selectedSpec.value,
    finalPrice: finalPrice.value
  }
  emit('add-to-cart', cartItem)
  emit('close')
  quantity.value = 1
  selectedSpec.value = ''
}
</script>

<style scoped>
.dish-detail {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.dish-header {
  position: relative;
  height: 300px;
}

.dish-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.close-btn {
  position: absolute;
  top: 16px;
  right: 16px;
  background: rgba(0, 0, 0, 0.5);
  color: white;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}

.dish-content {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
}

.dish-content h2 {
  margin: 0 0 12px 0;
  font-size: 20px;
  font-weight: bold;
}

.dish-desc {
  color: #666;
  font-size: 14px;
  line-height: 1.5;
  margin-bottom: 16px;
}

.dish-price {
  display: flex;
  align-items: baseline;
  gap: 8px;
  margin-bottom: 24px;
}

.price {
  color: #ff6b6b;
  font-size: 24px;
  font-weight: bold;
}

.original-price {
  color: #999;
  font-size: 16px;
  text-decoration: line-through;
}

.dish-specs,
.dish-ingredients {
  margin-bottom: 24px;
}

.dish-specs h3,
.dish-ingredients h3 {
  font-size: 16px;
  font-weight: bold;
  margin-bottom: 12px;
}

.spec-options {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.spec-item {
  padding: 8px 16px;
  border: 1px solid #ddd;
  border-radius: 20px;
  cursor: pointer;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 4px;
}

.spec-item.active {
  border-color: #ff6b6b;
  color: #ff6b6b;
  background: #fff5f5;
}

.spec-price {
  font-size: 12px;
  color: #ff6b6b;
}

.ingredient-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.ingredient {
  background: #f5f5f5;
  color: #666;
  padding: 4px 12px;
  border-radius: 16px;
  font-size: 12px;
}

.dish-actions {
  position: sticky;
  bottom: 0;
  background: white;
  padding: 16px 0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-top: 1px solid #eee;
}

.quantity-control {
  flex: 1;
}

.add-to-cart-btn {
  background: #ff6b6b;
  color: white;
  padding: 12px 32px;
  border-radius: 24px;
  font-weight: bold;
  cursor: pointer;
  margin-left: 16px;
}

.add-to-cart-btn:hover {
  background: #ff5252;
}
</style>