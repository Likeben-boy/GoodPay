import config from "@/config";
import { ValidationError, TimeOutTokenError, HttpError } from "./error";

// 用户工具函数
const userUtils = {
  // 获取token
  getToken: () => localStorage.getItem("token") || "",
  // 获取refreshToken
  getRefreshToken: () => localStorage.getItem("refreshToken") || "",
  // 更新token
  updateToken: (accessToken) => {
    localStorage.setItem("token", accessToken);
  },
  // 清除用户信息
  clearUser: () => {
    localStorage.removeItem("token");
    localStorage.removeItem("refreshToken");
    localStorage.removeItem("userInfo");
  },
};

const BASE_URL = config.api.baseURL;
const TIME_OUT = config.api.timeout;

// 判断是否为开发环境
const isDevelopment = config.features.debug;
const shouldLog = config.features.logRequests;

//日志工具
const logger = {
  request: (url, method, data, params) => {
    if (isDevelopment && shouldLog) {
      console.group(`🚀 API 请求: ${method.toUpperCase()} ${url}`);
      console.log("📤 Data:", data);
      console.log("🔍 Params:", params);
      console.log("⏰ Time:", new Date().toLocaleTimeString());
      console.groupEnd();
    }
  },

  response: (url, response, duration) => {
    if (isDevelopment && shouldLog) {
      console.group(`✅ API Response: ${url}`);
      console.log("📥 Response:", response);
      console.log("⏱️ Duration:", `${duration}ms`);
      console.log("⏰ Time:", new Date().toLocaleTimeString());
      console.groupEnd();
    }
  },
  error: (url, error, response, duration) => {
    if (isDevelopment) {
      console.group(`❌ API Error: ${url}`);
      console.error("💥 Error:", error);
      console.error("💥 Response:", response);
      console.log("⏱️ Duration:", `${duration}ms`);
      console.log("⏰ Time:", new Date().toLocaleTimeString());
      console.groupEnd();
    }
  },
};

class HttpRequest {
  constructor() {
    this.baseURL = BASE_URL;
    this.timeout = TIME_OUT;
  }

  // 处理token刷新的方法
  async handleTokenRefresh(oldOptions, resolve, reject) {
    try {
      // 发送刷新token请求
      const refreshTokenResponse = await this.post("/users/refresh-token", {
        refreshToken: userUtils.getRefreshToken(),
      });
      
      if (!refreshTokenResponse.data) {
        throw new Error("refreshTokenResponse.data不能为空");
      }
      // 更新token到localStorage
      userUtils.updateToken(refreshTokenResponse.data.accessToken);

      // 用新的token重新发送原请求
      const retryResult = await this.request(oldOptions);
      resolve(retryResult);
    } catch (refreshError) {
      console.error("刷新token失败", refreshError);
      refreshError.message = "登陆信息失效2";
      // 清除用户信息并跳转到登录页
      userUtils.clearUser();
      // setTimeout(() => {
      //   window.location.replace("/login");
      // }, 1500);
      reject(refreshError);
    }
  }

  request(options) {
    const { url, method, data, params, headers = {} } = options;
    const startTime = Date.now(); // 记录开始时间

    // 获取token
    const token = userUtils.getToken();
    if (token) {
      headers["Authorization"] = `Bearer ${token}`;
    }

    // 构建完整URL
    const fullUrl = `${this.baseURL}${url}${
      params ? "?" + new URLSearchParams(params) : ""
    }`;
    logger.request(url, method, data, params);
    const config = {
      method,
      headers: {
        "Content-Type": "application/json",
        ...headers,
      },
      timeout: this.timeout,
    };

    if (method.toUpperCase() !== "GET" && data) {
      config.body = JSON.stringify(data);
    }

    return new Promise((resolve, reject) => {
      const timeoutId = setTimeout(() => {
        const duration = Date.now() - startTime; // 实际等待时间
        const timeoutError = new Error("请求超时");
        logger.error(url, timeoutError, duration);
        reject(timeoutError);
      }, this.timeout);

      fetch(fullUrl, config)
        .then(async (response) => {
          clearTimeout(timeoutId);
          const duration = Date.now() - startTime;

          if (!response.ok) {
            
            
            const errorData = await response.json().catch(() => ({}));
            let error;
            //根据错误码判断是什么错误
            switch (errorData.code) {
              //如果是校验错误，则把所有校验错误都保存进去
              case "VALIDATION_ERROR":
                error = new ValidationError(errorData.errors);
                break;

              //如果是token超时，则重新调用刷新token的接口并重新按照相同的参数重新发送一次接口
              case "TIME_OUT_TOKEN":
                console.log('是否进入3',errorData.code);
                error = new TimeOutTokenError(options);
                break;

              default:
                error = new HttpError(
                  errorData.code,
                  errorData.message ||
                    `HTTP ${(response.status, errorData.status)}`
                )
            }
            
            logger.error(url, error, errorData, duration);
            throw error;
          }

          const data = await response.json();
          logger.response(url, data, duration);
          resolve(data);
        })
        .catch((error) => {
          clearTimeout(timeoutId);
          const duration = Date.now() - startTime;

          // 处理自定义错误
          if (error.code) {
            switch (error.code) {
              case "TIME_OUT_TOKEN":
                // 直接刷新token，不处理并发问题
                // 因为JavaScript是单线程的，实际并发情况很少
                this.handleTokenRefresh(error.oldOptions, resolve, reject);
                return;

              // 如果是无效token的code，清除token信息并跳转登录页
              case "INVALID_TOKEN":
                userUtils.clearUser();
                error.message = "登陆信息失效1";
                setTimeout(() => {
                  window.location.replace("/login");
                }, 1500);
                break;
            }
          }

          reject(error);
        });
    });
  }

  get(url, params, config = {}) {
    return this.request({ url, method: "GET", params, ...config });
  }

  post(url, data, config = {}) {
    return this.request({ url, method: "POST", data, ...config });
  }

  put(url, data, config = {}) {
    return this.request({ url, method: "PUT", data, ...config });
  }

  delete(url, config = {}) {
    return this.request({ url, method: "DELETE", ...config });
  }
}

export const request = new HttpRequest();
