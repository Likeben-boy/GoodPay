<template>
  <div class="login-page">
    <div class="login-container">
      <div class="login-header">
        <h1>GoodPay</h1>
        <p>美味生活，一键下单</p>
      </div>

      <van-tabs v-model:active="activeTab" type="card" class="login-tabs">
        <van-tab title="手机登录" name="phone">
          <van-form @submit="onPhoneLogin" class="login-form">
            <van-field
              v-model="phoneForm.phone"
              type="tel"
              label="手机号"
              placeholder="请输入手机号"
              :rules="[
                { required: true, message: '请输入手机号' },
                { pattern: /^1[3-9]\d{9}$/, message: '手机号格式不正确' },
              ]"
            />
            <van-field
              v-model="phoneForm.authCode"
              type="digit"
              label="验证码"
              placeholder="请输入验证码"
              :rules="[{ required: true, message: '请输入验证码' }]"
            >
              <template #button>
                <van-button
                  size="small"
                  type="primary"
                  :disabled="countdown > 0"
                  @click="sendCode"
                >
                  {{ countdown > 0 ? `${countdown}s` : "获取验证码" }}
                </van-button>
              </template>
            </van-field>
            <div class="form-actions">
              <van-button round block type="primary" native-type="submit">
                登录
              </van-button>
            </div>
          </van-form>
        </van-tab>

        <van-tab title="密码登录" name="password">
          <van-form @submit="onPhoneLogin" class="login-form">
            <van-field
              v-model="phoneForm.phone"
              type="tel"
              label="手机号"
              placeholder="请输入手机号"
              :rules="[
                { required: true, message: '请输入手机号' },
                { pattern: /^1[3-9]\d{9}$/, message: '手机号格式不正确' },
              ]"
            />
            <van-field
              v-model="phoneForm.password"
              type="password"
              label="密码"
              placeholder="请输入密码"
              :rules="[{ required: true, message: '请输入密码' }]"
            />
            <div class="form-actions">
              <van-button round block type="primary" native-type="submit">
                登录
              </van-button>
            </div>
          </van-form>
        </van-tab>
      </van-tabs>

      <div class="login-footer">
        <div class="quick-login">
          <span>快速登录</span>
        </div>
        <div class="social-login">
          <van-icon
            name="wechat"
            size="24"
            color="#07c160"
            @click="wechatLogin"
          />
          <van-icon
            name="alipay"
            size="24"
            color="#1677ff"
            @click="alipayLogin"
          />
        </div>
        <div class="register-link">
          <span>还没有账号？</span>
          <span class="link" @click="goToRegister">立即注册</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from "vue";
import { useRouter } from "vue-router";
// import { showToast, showSuccessToast } from "vant";
import { useUserStore } from "@/store/user";
import { authApi } from "@/api/auth";

const router = useRouter();
const userStore = useUserStore();

const activeTab = ref("password");
const countdown = ref(0);

// 手机登录表单
const phoneForm = reactive({
  phone: "",
  authCode: "",
  password: "",
});

// 发送验证码
const sendCode = async () => {
  if (!phoneForm.phone) {
    showToast("请输入手机号");
    return;
  }

  if (!/^1[3-9]\d{9}$/.test(phoneForm.phone)) {
    showToast("手机号格式不正确");
    return;
  }

  try {
    // TODO: 调用发送验证码API
    showToast("验证码已发送");

    // 开始倒计时
    countdown.value = 60;
    const timer = setInterval(() => {
      countdown.value--;
      if (countdown.value <= 0) {
        clearInterval(timer);
      }
    }, 1000);
    phoneForm.authCode = 1234;
  } catch (error) {
    showToast("发送失败，请重试");
  }
};

// 手机验证码登录
const onPhoneLogin = async () => {
  try {
    const result = await authApi.login({
      phone: phoneForm.phone,
      authCode: phoneForm.authCode,
      password: phoneForm.password,
    });
    //存入登陆信息
    userStore.saveUser(result.data);
    router.replace("/");
    showSuccessToast("登录成功");
  } catch (error) {
    showToast(error.message || "登录失败，请重试");
  }
};

// 微信登录
const wechatLogin = () => {
  showToast("微信登录待实现");
  // TODO: 实现微信登录
};

// 支付宝登录
const alipayLogin = () => {
  showToast("支付宝登录待实现");
  // TODO: 实现支付宝登录
};

// 跳转到注册页面
const goToRegister = () => {
  router.push("/register");
};
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.login-container {
  width: 100%;
  max-width: 400px;
  background: white;
  border-radius: 16px;
  padding: 32px 24px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
}

.login-header {
  text-align: center;
  margin-bottom: 32px;
}

.login-header h1 {
  margin: 0 0 8px 0;
  font-size: 32px;
  font-weight: bold;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.login-header p {
  margin: 0;
  color: #666;
  font-size: 14px;
}

.login-tabs {
  margin-bottom: 24px;
}

.login-form {
  margin-top: 24px;
}

.form-actions {
  margin-top: 24px;
}

.login-footer {
  text-align: center;
  margin-top: 32px;
}

.quick-login {
  color: #666;
  font-size: 14px;
  margin-bottom: 16px;
  position: relative;
}

.quick-login::before,
.quick-login::after {
  content: "";
  position: absolute;
  top: 50%;
  width: 60px;
  height: 1px;
  background: #e5e5e5;
}

.quick-login::before {
  left: 20px;
}

.quick-login::after {
  right: 20px;
}

.social-login {
  display: flex;
  justify-content: center;
  gap: 32px;
  margin-bottom: 24px;
}

.social-login .van-icon {
  cursor: pointer;
  transition: transform 0.2s;
}

.social-login .van-icon:hover {
  transform: scale(1.1);
}

.register-link {
  color: #666;
  font-size: 14px;
}

.register-link .link {
  color: #667eea;
  font-weight: 500;
  cursor: pointer;
}
</style>
