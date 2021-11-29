import Vue from 'vue'
import Router from 'vue-router'
import Authentication from '@/components/Authentication'
import Dashboard from '@/components/Dashboard'
import DailyStatistics from '@/components/DailyStatistics'
import AdminDashboard from '@/components/admin/AdminDashboard'
import Report from '@/components/admin/Report'
import Form from '@/components/foods/Form'

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
      path: '/daily_statistics',
      name: 'DailyStatistics',
      component: DailyStatistics
    },
    {
      path: '/admin/dashboard',
      name: 'AdminDashboard',
      component: AdminDashboard
    },
    {
      path: '/foods/new',
      name: 'FoodNew',
      component: Form
    },
    {
      path: '/foods/edit/:id',
      name: 'FoodEdit',
      component: Form
    },
    {
      path: '/admin/report',
      name: 'Report',
      component: Report
    }
  ]
})
