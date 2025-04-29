const ApiEndpoints = {
  Auth: {
    LOGIN: () => `/api/auth/login`,
    REGISTER: () => `/api/auth/signup`,
    FORGOT_PASSWORD: () => `/api/auth/request-password-reset`,
    RESET_PASSWORD: () => `/api/auth/reset-password`,
    REFRESH_TOKEN: () => `/api/auth/refresh-token`
  }
};

export default ApiEndpoints;
