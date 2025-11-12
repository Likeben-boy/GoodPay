<template>
  <div class="order-processing">
    <van-nav-bar title="订单处理中" left-arrow @click-left="goBack" />

    <div class="processing-content">
      <div class="processing-icon">
        <van-loading size="60px" color="#1989fa" />
      </div>

      <h2 class="processing-title">订单正在处理</h2>

      <div class="order-info">
        <p class="order-number">订单号：{{ operation.orderNumber }}</p>
        <p class="payment-method">
          支付方式：{{ getPaymentMethodText(operation.paymentMethod) }}
        </p>
      </div>

      <div class="processing-tips">
        <van-notice-bar
          left-icon="info-o"
          text="正在为您处理订单，请稍候..."
          background="#f0f9ff"
          color="#1989fa"
        />
      </div>

      <div class="processing-steps">
        <van-steps direction="vertical" :active="currentStep">
          <van-step>订单创建成功</van-step>
          <van-step>支付处理中</van-step>
          <van-step>等待商家接单(模拟)</van-step>
          <van-step>等待骑手配送(模拟)</van-step>
        </van-steps>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { orderApi } from "@/api";

// 接收路由传递的地址数据
const props = defineProps({
  operation: {
    type: Object,
    default: null,
  },
});

const router = useRouter();

// 当前步骤
const currentStep = ref(1);

// 支付方式映射
const paymentMethodMap = {
  alipay: "支付宝",
  wechat: "微信支付",
  balance: "余额支付",
};

// 获取支付方式文本
const getPaymentMethodText = (method) => {
  return paymentMethodMap[method] || method;
};

// 返回上一页
const goBack = () => {
  router.back();
};

// 模拟订单处理过程
const processOrder = async () => {
  const orderId = Number(props.operation.orderId)
  try {
    // 模拟处理时间
    await new Promise((resolve) => setTimeout(resolve, 1000));

    //调用支付接口
    try {
      await orderApi.payOrder( orderId );
    } catch (error) {
      console.log(error.message);
      //TODO 如果失败以后调用查询接口,轮询三次,如果都没有得到终态,则返回订单详情
    }

    // 更新步骤到"等待商家接单"
    currentStep.value = 2;
    //调用商家切换状态
    await orderApi.changeStatus(
      orderId,
      "preparing",
    );

    // 更新步骤到"等待骑手接单"
    currentStep.value = 3;

    // 调用修改状态到骑手配送中
    await orderApi.changeStatus(
      orderId,"delivering",
    );

    // 跳转到订单成功页面
    router.replace({
      path: "/order/success",
      query: {
        orderId
      },
    });
  } catch (error) {
    console.error("订单处理失败:", error);
    // 可以跳转到订单失败页面或返回订单详情
    // router.push({ name: 'OrderDetail', params: { orderId} })
    router.push(`/order/${orderId}`);
  }
};

onMounted(() => {
  // 开始处理订单
  processOrder()
});
</script>

<style scoped>
.order-processing {
  min-height: 100vh;
  background-color: #f7f8fa;
}

.processing-content {
  padding: 40px 20px;
  text-align: center;
}

.processing-icon {
  margin-bottom: 24px;
}

.processing-title {
  font-size: 24px;
  font-weight: 600;
  color: #323233;
  margin: 0 0 32px 0;
}

.order-info {
  background: white;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 20px;
  text-align: left;
}

.order-number {
  font-size: 16px;
  font-weight: 500;
  color: #323233;
  margin: 0 0 8px 0;
}

.payment-method {
  font-size: 14px;
  color: #969799;
  margin: 0;
}

.processing-tips {
  margin-bottom: 32px;
}

.processing-steps {
  background: white;
  border-radius: 8px;
  padding: 20px;
  text-align: left;
}
</style>
