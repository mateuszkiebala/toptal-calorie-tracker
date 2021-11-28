<template>
  <nav class="navbar rounded">
    <ul class="navbar">
      <li class="nav-item home">
        <router-link class="nav-link" to="/dashboard">Home</router-link>
      </li>
      <li class="nav-item new-product">
        <router-link class="nav-link" to="/foods/new">New Product</router-link>
      </li>
    </ul>
    <ul class="navbar ml-auto">
      <li class="nav-item" v-if="showAdminLink()">
        <router-link class="nav-link" to="/admin/report">Reports</router-link>
      </li>
      <li class="nav-item" v-if="showAdminLink()">
        <router-link class="nav-link" to="/admin/dashboard">Admin</router-link>
      </li>
      <li class="nav-item sign-out">
        <a class="nav-link" @click="signOut">Sign out</a>
      </li>
    </ul>
  </nav>
</template>

<script>
export default {
  name: 'AppHeader',
  methods: {
    signOut () {
      this.$store.commit('unsetCurrentUser')
      this.$router.replace('/')
    },
    showAdminLink () {
      return this.$store.getters.isAdmin
    }
  }
}
</script>

<style lang="css">
  .navbar {
    padding-right: 0;
    padding-left: 0;
  }
  .navbar a {
    cursor: pointer;
    color: #212529;
  }
  .navbar ul {
    list-style: none;
  }
  .navbar .sign-out {
    padding-right: 0;
  }
  .navbar .home {
    padding-left: 0;
  }
</style>
