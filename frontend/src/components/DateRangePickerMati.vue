<template>
  <date-range-picker
    v-model="dateRange"
    @update="$emit('update-date-range', $event)"
  >
  </date-range-picker>
</template>

<script>
import DateRangePicker from 'vue2-daterange-picker'
import 'vue2-daterange-picker/dist/vue2-daterange-picker.css'

export default {
  name: 'DateRangePickerMati',
  data () {
    return {
      dateRange: {
        startDate: '2019-12-26',
        endDate: '2019-12-28'
      }
    }
  },
  components: { DateRangePicker }
}
</script>
