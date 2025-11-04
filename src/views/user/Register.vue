<template>
  <div class="register-page">
    <div class="register-container">
      <div class="register-header">
        <h1>GoodPay</h1>
        <p>美味生活，一键下单</p>
      </div>

      <van-form @submit="onRegister" class="register-form">
        <van-field
          v-model="registerForm.phone"
          type="tel"
          label="手机号"
          placeholder="请输入手机号"
          :rules="[
            { required: true, message: '请输入手机号' },
            { pattern: /^1[3-9]\d{9}$/, message: '手机号格式不正确' }
          ]"
        />

        <van-field
          v-model="registerForm.password"
          type="password"
          label="密码"
          placeholder="请设置密码（6-20位）"
          :rules="[
            { required: true, message: '请设置密码' },
            { pattern: /^[a-zA-Z0-9]{6,20}$/, message: '密码为6-20位字母或数字' }
          ]"
        />
        <van-field
          v-model="registerForm.confirmPassword"
          type="password"
          label="确认密码"
          placeholder="请再次输入密码"
          :rules="[
            { required: true, message: '请再次输入密码' },
            { validator: validateConfirmPassword, message: '两次密码输入不一致' }
          ]"
        />
                <van-field
          v-model="registerForm.authCode"
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
              {{ countdown > 0 ? `${countdown}s` : '获取验证码' }}
            </van-button>
          </template>
        </van-field>
        <div class="form-actions">
          <van-button round block type="primary" native-type="submit">
            注册
          </van-button>
        </div>
      </van-form>

      <div class="register-footer">
        <div class="agreement">
          <van-checkbox v-model="agreeTerms">
            我已阅读并同意
            <span class="link" @click="showUserAgreement">《用户协议》</span>
            和
            <span class="link" @click="showPrivacyPolicy">《隐私政策》</span>
          </van-checkbox>
        </div>
        <div class="login-link">
          <span>已有账号？</span>
          <span class="link" @click="goToLogin">立即登录</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { showToast, showSuccessToast, showDialog } from 'vant'
import  {useUserStore}  from '@/store/user'
import { authApi } from '@/api'

const router = useRouter()
const userStore = useUserStore()

const countdown = ref(0)
const agreeTerms = ref(false)

// 注册表单
const registerForm = reactive({
  phone: '',
  authCode: '',
  password: '',
  confirmPassword: ''
})

// 发送验证码
const sendCode = async () => {
  if (!registerForm.phone) {
    showToast('请输入手机号')
    return
  }

  if (!/^1[3-9]\d{9}$/.test(registerForm.phone)) {
    showToast('手机号格式不正确')
    return
  }

  try {
    // TODO: 调用发送验证码API,后端暂时不交验
    showToast('验证码已发送')
    registerForm.authCode = '1234'

    // 开始倒计时
    countdown.value = 60
    const timer = setInterval(() => {
      countdown.value--
      if (countdown.value <= 0) {
        clearInterval(timer)
      }
    }, 1000)
  } catch (error) {
    showToast('发送失败，请重试')
  }
}

// 验证确认密码
const validateConfirmPassword = (value) => {
  return value === registerForm.password
}

// 注册
const onRegister = async () => {
  if (!agreeTerms.value) {
    showToast('请先同意用户协议和隐私政策')
    return
  }

  try {
    const result = await authApi.register({
      phone: registerForm.phone,
      authCode: registerForm.authCode,
      password: registerForm.password
    })
      showSuccessToast('注册成功')
      userStore.saveUser(result);
      router.replace('/')
  } catch (error) {
    showToast(error.message ||'注册失败，请重试')
  }
}

// 显示用户协议
const showUserAgreement = () => {
  showDialog({
    title: '用户协议',
    message: '这里是用户协议内容...',
    confirmButtonText: '我已阅读'
  })
}

// 显示隐私政策
const showPrivacyPolicy = () => {
  showDialog({
    title: '隐私政策',
    message: '这里是隐私政策内容...',
    confirmButtonText: '我已阅读'
  })
}

// 跳转到登录页面
const goToLogin = () => {
  router.replace('/login')
}
</script>

<style scoped>
.register-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.register-container {
  width: 100%;
  max-width: 400px;
  background: white;
  border-radius: 16px;
  padding: 32px 24px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
}

.register-header {
  text-align: center;
  margin-bottom: 32px;
}

.register-header h1 {
  margin: 0 0 8px 0;
  font-size: 32px;
  font-weight: bold;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.register-header p {
  margin: 0;
  color: #666;
  font-size: 14px;
}

.register-form {
  margin-top: 24px;
}

.form-actions {
  margin-top: 24px;
}

.register-footer {
  text-align: center;
  margin-top: 32px;
}

.agreement {
  margin-bottom: 24px;
  font-size: 14px;
  color: #666;
  text-align: left;
}

.agreement .link {
  color: #667eea;
  font-weight: 500;
  cursor: pointer;
}

.login-link {
  color: #666;
  font-size: 14px;
}

.login-link .link {
  color: #667eea;
  font-weight: 500;
  cursor: pointer;
}
</style>