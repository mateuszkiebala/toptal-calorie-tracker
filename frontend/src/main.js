import Vue from 'vue'
import App from './App'
import router from './router'
import { store } from './store'
import VueAxios from 'vue-axios'
import VueFormulate from '@braid/vue-formulate'
import BootstrapVue from 'bootstrap-vue'
import { plainAxiosInstance } from './backend/axios'

Vue.config.productionTip = false
Vue.use(VueAxios, {
  plain: plainAxiosInstance
})

Vue.use(VueFormulate)
Vue.use(BootstrapVue)

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  store,
  VueFormulate,
  BootstrapVue,
  plainAxiosInstance,
  components: { App },
  template: '<App/>'
})
