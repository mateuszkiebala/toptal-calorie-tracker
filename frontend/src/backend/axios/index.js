import axios from 'axios'
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

export { plainAxiosInstance }
