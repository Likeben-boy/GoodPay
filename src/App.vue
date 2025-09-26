<template>

  <main>
    <RouterView />
  </main>
      <!-- 底部导航栏 -->
    <van-tabbar v-model="activeTab" route>
      <van-tabbar-item replace to="/" icon="home-o">首页</van-tabbar-item>
      <van-tabbar-item replace to="/order" icon="orders-o">订单</van-tabbar-item>
      <van-tabbar-item replace to="/user" icon="user-o">我的</van-tabbar-item>
    </van-tabbar>
</template>

<script setup>
import HomeView from './views/home/HomeView.vue'
import { useRouter } from 'vue-router'
</script>

<style scoped>


</style>
