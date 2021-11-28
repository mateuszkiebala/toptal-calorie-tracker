import Vue from 'vue'
import App from './App'
import router from './router'
import { store } from './store'
import VueAxios from 'vue-axios'
import BootstrapVue from 'bootstrap-vue'
import Vuelidate from 'vuelidate'
import { plainAxiosInstance } from './backend/axios'
import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'

Vue.config.productionTip = false
Vue.use(VueAxios, {
  plain: plainAxiosInstance
})

Vue.use(BootstrapVue)
Vue.use(Vuelidate)

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  store,
  plainAxiosInstance,
  components: { App },
  template: '<App/>'
})
