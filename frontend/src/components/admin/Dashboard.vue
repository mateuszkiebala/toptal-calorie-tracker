<template>
  <div class="container">
    <AppHeader></AppHeader>
    <List fetch-foods-path="/admin/foods"></List>
  </div>
</template>

<script>
import AppHeader from '@/components/AppHeader'
import List from '@/components/foods/List'

export default {
  name: 'AdminDashboard',
  data () {
    return {
    }
  },
  components: { AppHeader, List }
}
</script>
