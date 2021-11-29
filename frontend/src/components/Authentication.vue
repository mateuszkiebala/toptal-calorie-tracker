<template>
  <form class="form-authentication" @submit.prevent="authenticate">
    <div class="alert alert-danger" v-if="error">{{ error }}</div>
    <div class="form-group">
      <label for="authToken">Authentication Token</label>
      <input v-model="authToken" type="password" class="form-control" id="authToken" placeholder="Authentication Token">
    </div>
    <button type="submit" class="btn btn-primary mb-3">Let's start</button>
  </form>
</template>

<script>
export default {
  name: 'Authentication',
  data () {
    return {
      authToken: '',
      error: ''
    }
  },
  created () {
    this.checkSignedIn()
  },
  updated () {
    this.checkSignedIn()
  },
  methods: {
    authenticate () {
      this.unauthenticated.get('/users/my_profile', { headers: { 'Authorization': this.authToken } })
        .then(response => this.authenticationSuccessful(response))
        .catch(error => this.authenticationFailed(error))
    },
    authenticationSuccessful (response) {
      this.$store.commit('setCurrentUser', { currentUser: response.data.data.attributes, authToken: this.authToken })
      this.error = ''
      this.$router.replace('/dashboard')
    },
    authenticationFailed (error) {
      this.error = (error.response && error.response.data.errors.detail) || ''
      this.$store.commit('unsetCurrentUser')
    },
    checkSignedIn () {
      if (this.$store.getters.signedIn) {
        this.$router.replace('/dashboard')
      }
    }
  }
}
</script>

<style lang="css">
  .form-authentication {
    width: 70%;
    max-width: 500px;
    padding: 10% 15px;
    margin: 0 auto;
  }
</style>
