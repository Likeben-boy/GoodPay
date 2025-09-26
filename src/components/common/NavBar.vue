<template>
  <van-nav-bar
    :title="title"
    :left-text="leftText"
    :left-arrow="leftArrow"
    :right-text="rightText"
    @click-left="onClickLeft"
    @click-right="onClickRight"
    :fixed="fixed"
    :placeholder="placeholder"
  >
    <template #left v-if="$slots.left">
      <slot name="left"></slot>
    </template>
    <template #right v-if="$slots.right">
      <slot name="right"></slot>
    </template>
  </van-nav-bar>
</template>

<script setup>
defineProps({
  title: {
    type: String,
    default: ''
  },
  leftText: {
    type: String,
    default: ''
  },
  leftArrow: {
    type: Boolean,
    default: false
  },
  rightText: {
    type: String,
    default: ''
  },
  fixed: {
    type: Boolean,
    default: true
  },
  placeholder: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['clickLeft', 'clickRight'])

const onClickLeft = () => {
  emit('clickLeft')
}

const onClickRight = () => {
  emit('clickRight')
}
</script>

<style scoped>
.van-nav-bar {
  background: #ffffff;
}

.van-nav-bar__title {
  color: #333;
  font-weight: 600;
}

.van-nav-bar__text {
  color: #667eea;
}

.van-nav-bar__arrow {
  color: #333;
}
</style>