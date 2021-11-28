import Vue from 'vue'
import Router from 'vue-router'
import Authentication from '@/components/Authentication'
import List from '@/components/foods/List'
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
      name: 'List',
      component: List
    },
    {
      path: '/admin/foods',
      name: 'AdminFoodList',
      component: AdminFoodList
    }
  ]
})
