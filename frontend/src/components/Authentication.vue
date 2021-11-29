<template>
  <form class="form-authentication" @submit.prevent="authenticate">
    <h3 style="margin-bottom: 2em">Welcome to CalorieTracker!</h3>
    <ErrorAlert :errors="serverErrors"></ErrorAlert>

    <div class="form-group">
      <label for="authToken">Authentication Token</label>
      <input v-model="authToken" type="password" class="form-control" id="authToken" placeholder="Enter Authentication Token">
    </div>
    <button type="submit" class="btn btn-primary mb-3">Let's start</button>
  </form>
</template>

<script>
import ErrorAlert from '@/components/ErrorAlert'

export default {
  name: 'Authentication',
  data () {
    return {
      authToken: '',
      serverErrors: []
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
      this.cleanErrors()
      this.$router.replace('/dashboard')
    },
    authenticationFailed (error) {
      this.serverErrors = this.parseServerErrors(error, 'Something went wrong during authenticating...')
      this.$store.commit('unsetCurrentUser')
    },
    checkSignedIn () {
      if (this.$store.getters.signedIn) {
        this.$router.replace('/dashboard')
      }
    },
    cleanErrors () {
      this.serverErrors = []
    }
  },
  components: { ErrorAlert }
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
