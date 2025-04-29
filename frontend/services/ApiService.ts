import axios, { AxiosError, AxiosResponse } from 'axios';
import ApiEndpoints from './ApiEndpoints';
import { router } from 'expo-router';

class ApiService {
  private defaultBaseURL: string;
  private axiosInstance: any;

  constructor() {
    this.defaultBaseURL = ApiEndpoints.BASE_URL;
    this.axiosInstance = axios.create({
      baseURL: this.defaultBaseURL,
      timeout: 30000,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }
    });

    this.setupInterceptors();
  }

  private setupInterceptors() {
    this.axiosInstance.interceptors.request.use(
      async (config: any) => {
        if (!config.skipAuth) {
          const accessToken = localStorage.getItem('accessToken');
          if (accessToken) {
            config.headers.Authorization = `Bearer ${accessToken}`;
          }
        }
        return config;
      },
      (error: AxiosError) => Promise.reject(error)
    );

    this.axiosInstance.interceptors.response.use(
      (response: AxiosResponse<any>) => {
        const res = response.data;
        if (res.success === false) {
          return Promise.reject({
            message: res.error?.message || 'Unknown error',
            error_code: res.error?.error_code || 'UNKNOWN_ERROR',
            path: res.error?.path,
            status: response.status
          });
        }
        return res.data;
      },
      async (error: AxiosError) => {
        const originalRequest = error.config as any;

        if (error.response?.status === 401 && !originalRequest._retry && !originalRequest.skipAuth) {
          originalRequest._retry = true;
          try {
            const refreshToken = localStorage.getItem('refreshToken');
            if (!refreshToken) {
              this.redirectToLogin();
              return Promise.reject(error);
            }

            const tokenResponse = await this.refreshAccessToken(refreshToken);
            if (tokenResponse && tokenResponse.access_token) {
              localStorage.setItem('accessToken', tokenResponse.access_token);
              originalRequest.headers.Authorization = `Bearer ${tokenResponse.access_token}`;
              return this.axiosInstance(originalRequest);
            } else {
              this.redirectToLogin();
              return Promise.reject(error);
            }
          } catch (refreshError) {
            this.redirectToLogin();
            return Promise.reject(refreshError);
          }
        }

        this.handleApiError(error);
        return Promise.reject(error);
      }
    );

  }

  private async refreshAccessToken(refreshToken: string) {
    try {
      const response = await axios.post(
        `${this.defaultBaseURL}${ApiEndpoints.Auth.REFRESH_TOKEN()}`,
        { refresh_token: refreshToken }
      );
      return response.data;
    } catch (error) {
      localStorage.removeItem('accessToken');
      localStorage.removeItem('refreshToken');
      throw error;
    }
  }

  private handleApiError(error: AxiosError) {
    if (!error.response) {
      console.error('Network Error:', error.message);
      return;
    }

    const { status } = error.response;

    switch (status) {
      case 400:
        console.error('Bad Request:', error.response.data);
        break;
      case 401:
        console.warn('Unauthorized access.');
        break;
      case 403:
        console.error('Forbidden:', error.response.data);
        break;
      case 404:
        console.error('Not Found:', error.response.data);
        break;
      case 500:
        console.error('Server Error:', error.response.data);
        break;
      default:
        console.error('Unhandled API Error:', error.response.data);
    }
  }

  private redirectToLogin() {
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
    router.replace('/');
  }

  private createRequest(method: string, endpoint: string, data = {}, customConfig = {}) {
    const config: any = { ...customConfig };

    let requestInstance = this.axiosInstance;

    if (customConfig.hasOwnProperty('baseURL')) {
      const baseURL = (customConfig as any).baseURL;
      delete config.baseURL;

      requestInstance = axios.create({
        baseURL,
        timeout: config.timeout || 30000,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...(config.headers || {}),
          ...(config.skipAuth ? {} : { Authorization: `Bearer ${localStorage.getItem('accessToken') || ''}` })
        }
      });

      requestInstance.interceptors.response.use(
        (response: AxiosResponse<any>) => response.data,
        (error: AxiosError) => Promise.reject(error)
      );
    }

    switch (method) {
      case 'GET':
        return requestInstance.get(endpoint, { params: data, ...config });
      case 'POST':
        return requestInstance.post(endpoint, data, config);
      case 'PUT':
        return requestInstance.put(endpoint, data, config);
      case 'PATCH':
        return requestInstance.patch(endpoint, data, config);
      case 'DELETE':
        return requestInstance.delete(endpoint, config);
      default:
        throw new Error(`Unsupported HTTP method: ${method}`);
    }
  }

  public async get(endpoint: string, params = {}, config = {}) {
    return await this.createRequest('GET', endpoint, params, config);
  }

  public async post(endpoint: string, data = {}, config = {}) {
    return await this.createRequest('POST', endpoint, data, config);
  }

  public async put(endpoint: string, data = {}, config = {}) {
    return await this.createRequest('PUT', endpoint, data, config);
  }

  public async delete(endpoint: string, config = {}) {
    return await this.createRequest('DELETE', endpoint, {}, config);
  }

  public async patch(endpoint: string, data = {}, config = {}) {
    return await this.createRequest('PATCH', endpoint, data, config);
  }

  public async login(credentials: any) {
    const response = await this.post(ApiEndpoints.Auth.LOGIN(), credentials, { skipAuth: true });
    if (response.access_token) {
      localStorage.setItem('accessToken', response.access_token);
    }
    if (response.refresh_token) {
      localStorage.setItem('refreshToken', response.refresh_token);
    }
    return response;
  }

  public async register(userData: any) {
    return await this.post(ApiEndpoints.Auth.REGISTER(), userData);
  }

  public async forgotPassword(email: string) {
    return await this.post(ApiEndpoints.Auth.FORGOT_PASSWORD(), { email });
  }

  public async resetPassword(data: any) {
    return await this.post(ApiEndpoints.Auth.RESET_PASSWORD(), data);
  }
}

const apiService = new ApiService();
export default apiService;