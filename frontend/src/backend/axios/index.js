import axios from 'axios'
import { store } from './../../store'

const API_URL = 'http://127.0.0.1:3000/api/v1'

const plainAxiosInstance = axios.create({
  baseURL: API_URL,
  withCredentials: true,
  headers: {
    'Content-Type': 'application/json'
  }
})

const unauthenticatedAxiosInstance = axios.create({
  baseURL: API_URL,
  withCredentials: true,
  headers: {
    'Content-Type': 'application/json'
  }
})

plainAxiosInstance.interceptors.request.use(function (config) {
  config.headers = {
    ...config.headers,
    'Authorization': store.state.authToken
  }
  return config
})

export { plainAxiosInstance, unauthenticatedAxiosInstance }
