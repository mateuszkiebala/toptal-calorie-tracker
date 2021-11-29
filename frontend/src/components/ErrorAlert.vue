<template>
  <div class="container">
    <h3 v-if="!noServerErrors()">Errors</h3>
    <ul class="errors">
      <li v-for="error in errors" :key="error" :error="error">
        <b-alert variant="danger" show>{{ error }}</b-alert>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  name: 'ErrorAlert',
  props: [ 'errors' ],
  methods: {
    noServerErrors () {
      return this.errors == null || this.errors.length === 0
    }
  }
}
</script>

<style lang="css">
  ul.errors {
    list-style-type: none;
    margin: 0;
    padding: 0;
  }
</style>
