<template>
  <div class="container">
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
        id="report-list"
        :busy.sync="isBusy"
        :items="fetchUserStatistics"
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
import moment from 'moment'

export default {
  name: 'Report',
  data () {
    return {
      error: '',
      isBusy: false,
      fields: [
        { key: 'user_id', label: 'User ID' },
        { key: 'average_calorie_value', label: 'Average calories for last 7 days' }
      ],
      totalRows: 0,
      currentPage: 1,
      perPage: 10,
      pageOptions: [5, 10, 15, { value: 100, text: 'Show a lot' }],
      global_statistics: {
        current: 0,
        previous: 0
      }
    }
  },
  created () {
    let startDate = moment().subtract(7, 'd').startOf('day').toISOString()
    let endDate = moment().endOf('day').toISOString()
    this.setGlobalStatistics(this.global_statistics.current, startDate, endDate)

    startDate = moment().subtract(14, 'd').startOf('day').toISOString()
    endDate = moment().subtract(8, 'd').startOf('day').toISOString()
    this.setGlobalStatistics(this.global_statistics.previous, startDate, endDate)
  },
  methods: {
    setError (error, text) {
      this.error = (error.response.errors[0] && error.response.errors[0].detail) || text
    },
    fetchUserStatistics (ctx) {
      if (!this.$store.getters.signedIn || !this.isAdmin()) {
        this.$router.replace('/')
      } else {
        let startDate = moment().subtract(7, 'd').startOf('day').toISOString()
        let endDate = moment().endOf('day').toISOString()
        let params = {
          'page[number]': this.currentPage,
          'page[size]': this.perPage,
          'filter[taken_at_gteq]': startDate,
          'filter[taken_at_lteq]': endDate
        }

        let promise = this.plain.get('/admin/foods/user_statistics', { params })
        return promise.then(response => {
          this.totalRows = response.data.meta.records
          return response.data.data.attributes.average_calories.map(function (stats) {
            return {
              user_id: stats.user_id,
              average_calorie_value: stats.value
            }
          })
        }).catch(error => {
          this.setError(error, 'Something went wrong')
          return []
        })
      }
    },
    setGlobalStatistics (dst, startDate, endDate) {
      if (!this.$store.getters.signedIn || !this.isAdmin()) {
        this.$router.replace('/')
      } else {
        let params = {
          'filter[taken_at_gteq]': startDate,
          'filter[taken_at_lteq]': endDate
        }

        this.plain.get('/admin/foods/global_statistics', { params })
          .then(response => {
            dst = response.data.data.attributes.entries_count
          }).catch(error => {
            this.setError(error, 'Something went wrong')
          })
      }
    },
    isAdmin () {
      return this.$store.getters.isAdmin
    }
  }
}
</script>
