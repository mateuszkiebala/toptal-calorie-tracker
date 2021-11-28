import axios from 'axios'
import Qs from 'query-string'
import { store } from './../../store'

const API_URL = 'http://127.0.0.1:3000/api/v1'

const plainAxiosInstance = axios.create({
  baseURL: API_URL,
  withCredentials: true,
  headers: {
    'Content-Type': 'application/json',
    'Authorization': store.state.authToken
  }
})

plainAxiosInstance.interceptors.request.use(config => {
  config.paramsSerializer = params => {
    return Qs.stringify(params, {
      arrayFormat: 'bracket',
      encode: true
    })
  }
  return config
})

export { plainAxiosInstance }
