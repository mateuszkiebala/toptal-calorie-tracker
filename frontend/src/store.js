import Vue from 'vue'
import Vuex from 'vuex'
import createPersistedState from 'vuex-persistedstate'
Vue.use(Vuex)

export const store = new Vuex.Store({
  state: {
    currentUser: {},
    authToken: null
  },
  getters: {
    signedIn (state) {
      return !!state.authToken
    },
    isAdmin (state) {
      return state.currentUser && state.currentUser.role === 'admin'
    },
    isRegular (state) {
      return state.currentUser && state.currentUser.role === 'regular'
    }
  },
  mutations: {
    setCurrentUser (state, { currentUser, authToken }) {
      state.currentUser = currentUser
      state.authToken = authToken
    },
    unsetCurrentUser (state) {
      state.currentUser = {}
      state.authToken = null
    }
  },
  plugins: [createPersistedState()]
})
