<template>
  <div class="container">
    <AppHeader></AppHeader>
    <ErrorAlert :errors="serverErrors"></ErrorAlert>

    <b-alert v-if="isCalorieLimitExceeded()" variant="warning" show>You have exceeded your daily calorie limit! {{ this.todayCalorieSum }} / {{ this.calorieLimit }}</b-alert>
    <b-alert v-if="isMoneyLimitExceeded()" variant="warning" show>You have exceeded your monthly money limit! {{ this.monthlyMoneySum }} / {{ this.moneyLimit }}</b-alert>

    <h3 style="margin-bottom: 2em; margin-top: 2em;">Daily statistics</h3>

    <b-form-group id="group-date-range" label="Filter by date:" label-for="date-range">
      <date-range-picker
        id="date-range"
        v-model="dateRange"
        @update="refreshTable"
      ></date-range-picker>
    </b-form-group>

    <b-container fluid>
      <!-- User Interface controls -->
      <b-row>
        <b-col sm="5" md="6" class="my-1">
          <b-form-group
            label="Per page"
            label-for="per-page-select"
            label-cols-sm="6"
            label-cols-md="4"
            label-cols-lg="3"
            label-align-sm="right"
            label-size="sm"
            class="mb-0"
          >
            <b-form-select
              id="per-page-select"
              v-model="perPage"
              :options="pageOptions"
              size="sm"
            ></b-form-select>
          </b-form-group>
        </b-col>

        <b-col sm="7" md="6" class="my-1">
          <b-pagination
            v-model="currentPage"
            :total-rows="totalRows"
            :per-page="perPage"
            align="fill"
            size="sm"
            class="my-0"
          ></b-pagination>
        </b-col>
      </b-row>

      <!-- Main table element -->
      <b-table
        id="daily-statistics-list"
        :busy.sync="isBusy"
        :items="fetchDailyStatistics"
        :fields="fields"
        :current-page="currentPage"
        :per-page="perPage"
        stacked="md"
        show-empty
        small
      >
        <template #cell(name)="row">
          {{ row.value.first }} {{ row.value.last }}
        </template>

        <template #row-details="row">
          <b-card>
            <ul>
              <li v-for="(value, key) in row.item" :key="key">{{ key }}: {{ value }}</li>
            </ul>
          </b-card>
        </template>
      </b-table>
    </b-container>
  </div>
</template>

<script>
import AppHeader from '@/components/AppHeader'
import ErrorAlert from '@/components/ErrorAlert'
import DateRangePicker from 'vue2-daterange-picker'
import 'vue2-daterange-picker/dist/vue2-daterange-picker.css'
import moment from 'moment'

export default {
  name: 'DailyStatistics',
  data () {
    return {
      serverErrors: [],
      todayCalorieSum: 0,
      monthlyMoneySum: 0,
      calorieLimit: 0,
      dateRange: {
        startDate: null,
        endDate: null
      },
      isBusy: false,
      fields: [
        { key: 'day', label: 'Day' },
        { key: 'calorie_sum', label: 'Calories' },
        { key: 'price_sum', label: 'Money spent' }
      ],
      totalRows: 0,
      currentPage: 1,
      perPage: 10,
      pageOptions: [5, 10, 15, { value: 100, text: 'Show a lot' }]
    }
  },
  created () {
    this.dateRange.startDate = moment().startOf('day').toISOString()
    this.dateRange.endDate = moment().endOf('day').toISOString()
    this.calorieLimit = parseFloat(this.$store.state.currentUser.calorie_limit)
    this.moneyLimit = parseFloat(this.$store.state.currentUser.money_limit)
    this.setTodayCalorieSum()
    this.setMonthlyMoneySum()
  },
  methods: {
    refreshTable (event) {
      this.$root.$emit('bv::refresh::table', 'daily-statistics-list')
    },
    fetchDailyStatistics (ctx) {
      let promise = this.fetchStatistics(this.dateRange.startDate, this.dateRange.endDate)
      return promise.then(response => {
        return response.data.data.attributes.values
      }).catch(error => {
        this.serverErrors = this.parseServerErrors(error, 'Something went wrong.')
        return []
      })
    },
    setTodayCalorieSum () {
      const startDate = moment().startOf('day').toISOString()
      const endDate = moment().endOf('day').toISOString()
      this.fetchStatistics(startDate, endDate).then(response => {
        this.todayCalorieSum = parseFloat(response.data.data.attributes.values[0].calorie_sum)
      }).catch(error => {
        this.serverErrors = this.parseServerErrors(error, 'Something went wrong.')
      })
    },
    setMonthlyMoneySum () {
      const startOfMonth = moment().startOf('month').toISOString()
      const endOfMonth = moment().endOf('month').toISOString()
      this.fetchStatistics(startOfMonth, endOfMonth).then(response => {
        this.monthlyMoneySum = response.data.data.attributes.values.map(function (dailyStat) {
          return parseFloat(dailyStat.price_sum)
        }).reduce(function (acc, priceSum) {
          return acc + priceSum
        })
      }).catch(error => {
        this.serverErrors = this.parseServerErrors(error, 'Something went wrong.')
      })
    },
    fetchStatistics (startDate, endDate) {
      if (!this.$store.getters.signedIn) {
        this.$router.replace('/')
      } else {
        let params = {
          'filter[taken_at_gteq]': startDate,
          'filter[taken_at_lteq]': endDate
        }
        return this.plain.get('/foods/daily_statistics', { params })
      }
    },
    isCalorieLimitExceeded () {
      return this.todayCalorieSum > this.calorieLimit
    },
    isMoneyLimitExceeded () {
      return this.monthlyMoneySum > this.moneyLimit
    },
    cleanErrors () {
      this.serverErrors = []
    }
  },
  components: { AppHeader, DateRangePicker, ErrorAlert }
}
</script>
