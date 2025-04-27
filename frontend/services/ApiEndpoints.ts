const BASE_URL = process.env.EXPO_PUBLIC_API_URL || "http://localhost:8000";

const ApiEndpoints = {
  BASE_URL,
  Auth: {
    LOGIN: () => '/auth/login',
    REGISTER: () => '/auth/register',
    FORGOT_PASSWORD: () => '/auth/forgot-password',
    RESET_PASSWORD: () => '/auth/reset-password',
    REFRESH_TOKEN: () => '/auth/refresh-token'
  }
};

export default ApiEndpoints;
