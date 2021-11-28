<template>
  <div class="dashboard">
    <AppHeader></AppHeader>
    <List></List>
  </div>
</template>

<script>
import AppHeader from '@/components/AppHeader'
import List from '@/components/foods/List'

export default {
  name: 'Dashboard',
  data () {
    return {
    }
  },
  components: { AppHeader, List }
}
</script>

<style lang="css">
.dashboard ul li:hover {
  background: #fcfcfc;
}
</style>
