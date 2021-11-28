<template>
  <div class="users">
    <AppHeader></AppHeader>
    <div class="alert alert-danger" v-if="error">{{ error }}</div>
    <h3>Users</h3>
    <br />
    <table class="table">
      <thead>
      <tr>
        <th>Name</th>
        <th>Calorie value</th>
        <th>Price</th>
        <th>Taken at</th>
      </tr>
      </thead>
      <tbody>
      <tr v-for="food in foods" :key="food.id" :food="food">
        <td>{{ food.name }}</td>
        <td>{{ food.calorie_value }}</td>
        <td>{{ food.price }}</td>
        <td>{{ food.taken_at }}</td>
      </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import AppHeader from '@/components/AppHeader'

export default {
  name: 'AdminFoodList',
  data () {
    return {
      error: '',
      foods: []
    }
  },
  created () {
    if (this.$store.getters.signedIn && this.$store.getters.isAdmin) {
      this.plain.get('/admin/foods')
        .then(response => {
          this.foods = response.data.data.map(function (food) {
            return food.attributes
          })
        })
        .catch(error => { this.setError(error, 'Something went wrong') })
    } else {
      this.$router.replace('/')
    }
  },
  methods: {
    setError (error, text) {
      this.error = (error.response && error.response.data.errors[0].detail) || text
    },
    showTodosLink () {
      return this.$store.getters.isAdmin
    }
  },
  components: { AppHeader }
}
</script>
