<template>
  <div class="order-list">
    <!-- 顶部导航 -->
    <!-- <van-nav-bar title="我的订单" /> -->

    <!-- 订单状态标签 -->
    <van-tabs
      v-model:active="activeStatus"
      class="status-tabs"
      @change="onTabChange"
      :lazy-render="false"
    >
      <van-tab title="全部" name="all"> </van-tab>
      <van-tab title="待支付" name="created"> </van-tab>
      <van-tab title="配送中" name="delivering"> </van-tab>
      <van-tab title="已完成" name="completed"> </van-tab>
    </van-tabs>

    <!-- 订单列表内容 -->
    <div class="orders-container">
      <van-list
        v-model:loading="loading"
        v-model:error="loadingError"
        :finished="finished"
        finished-text="没有更多了"
        loading-text="加载中..."
        error-text="请求失败,点击重新加载"
        @load="onLoad"
      >
        <div
          v-for="order in orders"
          :key="order.id"
          class="order-card"
          @click="goToOrderDetail(order.id)"
        >
          <div class="order-header">
            <div class="restaurant-info">
              <div class="restaurant-details">
                <h4>{{ order.restaurantName }}</h4>
                <span class="order-time">{{
                  formatTime(order.createdAt)
                }}</span>
              </div>
            </div>
            <div class="status-container">
              <span :class="['order-status', order.orderStatus]">{{
                getStatusText(order.orderStatus)
              }}</span>
              <span :class="['payment-status', order.paymentStatus]">{{
                getPaymentStatusText(order.paymentStatus)
              }}</span>
            </div>
          </div>

          <div class="order-items">
            <div
              v-for="item in order.orderItems"
              :key="item.id"
              class="order-item"
            >
              <img
                :src="item.dishImage"
                :alt="item.dishName"
                class="item-image"
              />
              <div class="item-info">
                <span class="item-name">{{ item.dishName }}</span>
                <span class="item-quantity">x{{ item.quantity }}</span>
              </div>
            </div>
          </div>

          <div class="order-footer">
            <div class="order-total">
              <span>共{{ getTotalItems(order.orderItems) }}件，合计</span>
              <span class="total-price">¥{{ order.totalAmount }}</span>
            </div>
            <div class="order-actions">
              <van-button
                v-if="order.orderStatus === 'created' && order.paymentStatus === 'pending'"
                type="primary"
                size="small"
                @click.stop="goToPayment(order)"
              >
                去支付
              </van-button>
              <van-button
                v-if="order.orderStatus === 'created' && order.paymentStatus === 'pending'"
                type="default"
                size="small"
                @click.stop="cancelOrder(order.id)"
              >
                取消订单
              </van-button>
              <van-button
                v-if="order.orderStatus === 'confirmed' || order.orderStatus === 'preparing'"
                type="default"
                size="small"
                @click.stop="contactRestaurant(order)"
              >
                联系商家
              </van-button>
              <van-button
                v-if="order.orderStatus === 'delivering'"
                type="primary"
                size="small"
                @click.stop="confirmReceipt(order.id)"
              >
                确认收货
              </van-button>
              <van-button
                v-if="order.orderStatus === 'completed'"
                type="default"
                size="small"
                @click.stop="refundOrder(order.id)"
              >
                申请退款
              </van-button>
              <!-- cancelled 状态不显示任何按钮 -->
            </div>
          </div>
        </div>

        <!-- 空状态 -->
        <div v-if="orders.length === 0 && !loading" class="empty-state">
          <van-icon name="orders-o" size="48" color="#969799" />
          <p>暂无订单</p>
        </div>
      </van-list>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { useRouter } from "vue-router";
import { orderApi } from "@/api";

const router = useRouter();
const activeStatus = ref("all");

// 分页数据
const pagination = ref({
  page: 1,
  limit: 5,
  total: 0,
  pages: 0,
  hasNext: false,
  hasPrev: false,
});

// 订单数据
const orders = ref([]);
const loading = ref(false);
const loadingError = ref(false);
const finished = ref(false);

// 获取订单状态文本
const getStatusText = (status) => {
  const statusMap = {
    created: "等待支付",
    confirmed: "订单已确认",
    preparing: "制作中",
    delivering: "配送中",
    completed: "已完成",
    cancelled: "已取消",
  };
  return statusMap[status] || status;
};

// 获取支付状态文本
const getPaymentStatusText = (status) => {
  const statusMap = {
    pending: "待支付",
    processing: "支付中",
    success: "支付成功",
    failed: "支付失败",
    refunded:"已退款",
  };
  return statusMap[status] || status;
};

// 格式化时间
const formatTime = (time) => {
  const date = new Date(time);
  return `${date.getMonth() + 1}月${date.getDate()}日 ${date.getHours()}:${date
    .getMinutes()
    .toString()
    .padStart(2, "0")}`;
};

// 计算订单总件数
const getTotalItems = (items) => {
  return items.reduce((total, item) => total + item.quantity, 0);
};

// 返回
const goBack = () => {
  router.back();
};

// 跳转到订单详情
const goToOrderDetail = (orderId) => {
  router.push(`/order/${orderId}`);
};

// 跳转到支付页面
const goToPayment = (orderItem) => {
  
  // 跳转到订单处理中页面
  router.push({
    path: "/order/processing",
    query: {
      orderId: orderItem.id,
      orderNumber: orderItem.orderNumber,
      paymentMethod: orderItem.paymentMethod,
    },
  });
};

// 通用弹框输入理由方法
const showReasonDialog = async (options) => {
  const {
    reasonPlaceholder,
    reasonTitle,
    successMessage,
    errorMessage,
    apiCall,
  } = options;

  // 清理之前可能存在的输入框
  const cleanupExistingInputs = () => {
    // 移除所有自定义创建的输入框容器
    const customInputs = document.querySelectorAll('.custom-dialog-input');
    customInputs.forEach(input => input.remove());

    // 恢复被隐藏的 message 元素
    const messageEls = document.querySelectorAll('.van-dialog__message');
    messageEls.forEach(el => {
      if (el.style.display === 'none') {
        el.style.display = '';
      }
    });
  };

  // 使用 prompt 弹框让用户输入理由
  const reason = await new Promise((resolve) => {
    // 清理旧的输入框
    cleanupExistingInputs();

    showDialog({
      title: reasonTitle,
      message: reasonPlaceholder,
      showCancelButton: true,
      confirmButtonText: "确认",
      cancelButtonText: "取消",
      closeOnPopstate: false,
      closeOnClickOverlay: false,
    })
      .then(() => {
        // 用户点击确认，获取输入值
        setTimeout(() => {
          const input = document.querySelector('.custom-dialog-input .van-dialog__input');
          resolve(input ? input.value.trim() : '');
        }, 100);
      })
      .catch(() => {
        // 用户点击取消
        resolve('');
      })
      .finally(() => {
        // 弹框关闭后清理输入框
        setTimeout(cleanupExistingInputs, 200);
      });

    // 创建输入框
    setTimeout(() => {
      const messageEl = document.querySelector('.van-dialog__message');
      if (messageEl) {
        messageEl.style.display = 'none';
        const inputContainer = document.createElement('div');
        inputContainer.className = 'custom-dialog-input';
        inputContainer.innerHTML = `
          <input type="text"
                 class="van-dialog__input"
                 placeholder="${reasonPlaceholder}"
                 style="width: 100%; padding: 8px; border: 1px solid #eee; border-radius: 4px; margin-top: 8px; box-sizing: border-box;">
        `;
        messageEl.parentNode.insertBefore(inputContainer, messageEl.nextSibling);
        inputContainer.querySelector('.van-dialog__input').focus();
      }
    }, 100);
  });

  // 如果用户没有输入理由或取消，直接返回
  if (!reason) {
    return;
  }

  try {
    await apiCall(reason);
    showToast(successMessage);
    // 刷新订单列表
    await resetAndLoadOrderList();
  } catch (error) {
    showToast(error.message || errorMessage);
  }
};

// 取消订单
const cancelOrder = (orderId) => {
  showReasonDialog({
    reasonPlaceholder: "请输入取消理由",
    reasonTitle: "取消理由",
    successMessage: "订单已取消",
    errorMessage: "取消订单失败，请重试",
    apiCall: (reason) => orderApi.cancelOrder(orderId, reason),
  });
};

// 联系商家
const contactRestaurant = (order) => {
  showToast('功能开发中...')
}

// 确认收货
const confirmReceipt = async (orderId) => {
  showToast('确认收货成功')
  // // 调用api
  await orderApi.confirmOrder(orderId);
  loadOrderList();
}

// 退款订单
const refundOrder = (orderId) => {
  showReasonDialog({
    reasonPlaceholder: "请输入退款理由",
    reasonTitle: "退款理由",
    successMessage: "订单已提交退款申请",
    errorMessage: "申请退款失败，请重试",
    apiCall: (reason) => orderApi.requestRefund(orderId, reason),
  });
};

// tab切换事件处理
const onTabChange = async () => {
  loadOrderList();
};

// 加载订单数据
const loadOrderList = async () => {
  try {
    const params = {
      page: 1,
      limit: 5,
    };
    if (activeStatus.value !== "all") {
      params.status = activeStatus.value;
    }

    const result = await orderApi.getOrderList(params);

    // 更新分页信息
    pagination.value = result.pagination;
      // 刷新时重置数据
      orders.value = result.data;
      console.log("重新刷新数据", result.data.length);

    // 判断是否还有更多数据 - 优先使用API返回的hasNext字段
    finished.value = !pagination.value.hasNext;
  } catch (error) {
    console.error("Load order list error:", error);
    showToast(error.message || "加载订单列表失败，请重试");
  }
};

// 追加订单数据
const addOrderList = async () => {
  try {
    const params = {
      page: pagination.value.page,
      limit: pagination.value.limit,
    };
    if (activeStatus.value !== "all") {
      params.status = activeStatus.value;
    }

    const result = await orderApi.getOrderList(params);

    // 更新分页信息
    pagination.value = result.pagination;
    
      // 加载更多时追加数据
      const newOrders = result.data;
      orders.value = [...orders.value, ...newOrders];
      console.log(
        "Appended new orders:",
        newOrders.length,
        "total orders:",
        orders.value.length
      );
    

    // 判断是否还有更多数据 - 优先使用API返回的hasNext字段
    finished.value = !pagination.value.hasNext;
    console.log(
      "Finished state:",
      finished.value,
      "hasNext:",
      pagination.value.hasNext
    );
    console.log(
      "Current page:",
      pagination.value.page,
      "Total pages:",
      pagination.value.pages
    );
  } catch (error) {
    console.error("Load order list error:", error);
    showToast(error.message || "加载订单列表失败，请重试");
    throw error; // 向上抛出错误，让外层统一处理loading状态
  }
};

// 重置并重新加载数据
const resetAndLoadOrderList = async () => {
  try {
    await loadOrderList();
  } catch (error) {
    console.error("Reset and load error:", error);
  }
};

// 加载更多数据
const onLoad = async () => {
  console.log(
    "onLoad triggered, finished:",
    finished.value,
    "current page:",
    pagination.value.page
  );

  try {

      //如果有错误,则重新加载页面
      if (loadingError.value) {
        await loadOrderList();
      }else{
      // 加载更多 - 递增页码
      pagination.value.page++;
      await addOrderList();
      }
      loadingError.value = false;
      loading.value = false
  } catch (error) {
    console.error("Load error:", error);
    // 加载失败时回滚页码
    loadingError.value = true;
    loading.value = false;
  }
};

onMounted(async () => {
  // 加载用户订单数据
  loadOrderList(true);
});
</script>

<style scoped>
.order-list {
  min-height: 100vh;
  background: #f5f5f5;
}

.status-tabs {
  background: #ffffff;
}

.loading-center {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 40px 0;
}

.orders-container {
  padding: 12px;
}

.order-card {
  background: #ffffff;
  border-radius: 8px;
  margin-bottom: 12px;
  overflow: hidden;
  cursor: pointer;
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border-bottom: 1px solid #f5f5f5;
}

.restaurant-info {
  display: flex;
  align-items: center;
}

.restaurant-details h4 {
  margin: 0 0 4px 0;
  font-size: 16px;
  font-weight: 600;
}

.order-time {
  font-size: 12px;
  color: #969799;
}

.status-container {
  display: flex;
  flex-direction: column;
  gap: 4px;
  align-items: flex-end;
}

.order-status {
  font-size: 12px;
  padding: 2px 8px;
  border-radius: 12px;
}

.order-status.created {
  color: #ff976a;
  background: #fff1e6;
}

.order-status.confirmed {
  color: #1989fa;
  background: #e6f3ff;
}

.order-status.preparing {
  color: #1989fa;
  background: #e6f3ff;
}

.order-status.delivering {
  color: #1989fa;
  background: #e6f3ff;
}

.order-status.completed {
  color: #07c160;
  background: #e6f7e6;
}

.order-status.cancelled {
  color: #ee0a24;
  background: #f7f7f7;
}

.payment-status {
  font-size: 11px;
  padding: 2px 6px;
  border-radius: 10px;
  font-weight: 500;
}

.payment-status.pending {
  color: #ff976a;
  background: #fff1e6;
}

.payment-status.processing {
  color: #1989fa;
  background: #e6f3ff;
}

.payment-status.success {
  color: #07c160;
  background: #e6f7e6;
}

.payment-status.failed {
  color: #ee0a24;
  background: #f7f7f7;
}

.payment-status.refunded {
  color: #909399;
  background: #f5f7fa;
}

.order-items {
  padding: 16px;
}

.order-item {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 8px;
}

.order-item:last-child {
  margin-bottom: 0;
}

.item-image {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  object-fit: cover;
}

.item-info {
  flex: 1;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.item-name {
  font-size: 14px;
  color: #333;
}

.item-quantity {
  font-size: 12px;
  color: #969799;
}

.order-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border-top: 1px solid #f5f5f5;
}

.order-total {
  font-size: 14px;
  color: #666;
}

.total-price {
  font-size: 16px;
  font-weight: bold;
  color: #ff6b6b;
}

.order-actions {
  display: flex;
  gap: 8px;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 0;
  color: #969799;
}

.empty-state p {
  margin: 16px 0 0 0;
  font-size: 14px;
}
</style>
