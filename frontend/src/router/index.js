import Vue from 'vue'
import Router from 'vue-router'
import Authentication from '@/components/Authentication'
import Dashboard from '@/components/Dashboard'
import AdminFoodList from '@/components/admin/foods/List'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'Authentication',
      component: Authentication
    },
    {
      path: '/dashboard',
      name: 'Dashboard',
      component: Dashboard
    },
    {
      path: '/admin/foods',
      name: 'AdminFoodList',
      component: AdminFoodList
    }
  ]
})
