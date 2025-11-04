/**
 * 包含所有错误
 */

class HttpError extends Error{
    constructor(code,message,status){
    super(message)
    this.code = code;
    this.status = status;
    this.message = message;
  }
}
    // 辅助函数：从 errors 数组生成错误消息
  function generateErrorMessage(errors) {
    console.log(errors);
    
  return Array.isArray(errors)
    ? errors.map(error => error.message).join('; ')
    : '校验错误';
}

//校验错误
class ValidationError extends HttpError {
  constructor(errors, code = 'VALIDATION_ERROR', status = 400) {
    super(code,generateErrorMessage(errors),status);
    this.code = code;
    this.status = status;
    this.errors = errors;
  }
}

//token超时
class TimeOutTokenError extends HttpError{
  constructor(oldOptions,code = 'TIME_OUT_TOKEN',status = 401){
    super(code,'访问token过期',status)
    this.code = code;
    this.status = status;
    this.oldOptions = oldOptions;
  }
}
export {
  HttpError,
  ValidationError,
  TimeOutTokenError
}