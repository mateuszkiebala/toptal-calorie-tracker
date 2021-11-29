import Vue from 'vue'
import Router from 'vue-router'
import Authentication from '@/components/Authentication'
import AdminDashboard from '@/components/admin/Dashboard'
import Dashboard from '@/components/Dashboard'
import DailyStatistics from '@/components/DailyStatistics'
import Report from '@/components/admin/Report'
import Form from '@/components/foods/Form'
import { store } from './../store'

Vue.use(Router)

let router = new Router({
  routes: [
    {
      path: '/',
      name: 'Authentication',
      component: Authentication
    },
    {
      path: '/dashboard',
      name: 'Dashboard',
      component: Dashboard,
      meta: {
        requiresAuth: true
      }
    },
    {
      path: '/daily_statistics',
      name: 'DailyStatistics',
      component: DailyStatistics,
      meta: {
        requiresAuth: true
      }
    },
    {
      path: '/foods/new',
      name: 'FoodNew',
      component: Form,
      meta: {
        requiresAuth: true
      }
    },
    {
      path: '/foods/edit/:id',
      name: 'FoodEdit',
      component: Form,
      meta: {
        requiresAuth: true,
        isAdmin: true
      }
    },
    {
      path: '/admin/dashboard',
      name: 'AdminDashboard',
      component: AdminDashboard,
      meta: {
        requiresAuth: true,
        isAdmin: true
      }
    },
    {
      path: '/admin/report',
      name: 'Report',
      component: Report,
      meta: {
        requiresAuth: true,
        isAdmin: true
      }
    },
    {
      path: '*',
      component: Dashboard,
      meta: {
        requiresAuth: true
      }
    }
  ]
})

router.beforeEach((to, from, next) => {
  if (to.matched.some(record => record.meta.requiresAuth)) {
    if (!store.getters.signedIn) {
      next({
        path: '/',
        params: {nextUrl: to.fullPath}
      })
    } else {
      if (to.matched.some(record => record.meta.isAdmin)) {
        if (store.getters.isAdmin) {
          next()
        } else {
          next({name: 'Dashboard'})
        }
      } else {
        next()
      }
    }
  } else {
    next()
  }
})

export default router
