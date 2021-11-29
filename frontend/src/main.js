import Vue from 'vue'
import App from './App'
import router from './router'
import { store } from './store'
import VueAxios from 'vue-axios'
import BootstrapVue from 'bootstrap-vue'
import Vuelidate from 'vuelidate'
import { plainAxiosInstance, unauthenticatedAxiosInstance } from './backend/axios'
import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'
import VueApexCharts from 'vue-apexcharts'
import moment from 'moment'

Vue.config.productionTip = false
Vue.use(VueAxios, {
  plain: plainAxiosInstance,
  unauthenticated: unauthenticatedAxiosInstance
})

Vue.use(BootstrapVue)
Vue.use(Vuelidate)

Vue.use(VueApexCharts)
Vue.component('apexchart', VueApexCharts)

Vue.mixin({
  methods: {
    parseServerErrors: function (errors, text) {
      console.log(errors)
      if (!errors) {
        return [text]
      }
      return errors.response.data.errors.map(function (error) {
        return error.detail
      })
    },
    dayStartString: function (datetime) {
      return moment(datetime).startOf('day').toISOString()
    },
    dayEndString: function (datetime) {
      return moment(datetime).endOf('day').toISOString()
    }
  }
})

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  store,
  plainAxiosInstance,
  unauthenticatedAxiosInstance,
  components: { App },
  template: '<App/>'
})
