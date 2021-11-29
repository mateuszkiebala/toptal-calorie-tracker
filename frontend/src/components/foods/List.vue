<template>
  <div class="container">
    <ErrorAlert :errors="serverErrors"></ErrorAlert>

    <h3 style="margin-bottom: 2em" v-if="isAllProductsView()">All Products</h3>
    <h3 style="margin-bottom: 2em" v-else>Your Products</h3>

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
        id="foods-list"
        :busy.sync="isBusy"
        :items="fetchData"
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

        <template v-if="isAdmin()" #cell(actions)="row">
          <i class="clickable fas fa-trash-alt mr-1" @click="removeFood(row.item, row.index, $event.target)"></i>
          <i class="clickable fas fa-edit mr-1" @click="updateFood(row.item, row.index, $event.target)"></i>
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
  name: 'List',
  props: [ 'fetchFoodsPath' ],
  data () {
    return {
      serverErrors: [],
      dateRange: {
        startDate: null,
        endDate: null
      },
      isBusy: false,
      fields: [
        { key: 'id', label: 'ID' },
        { key: 'food_name', label: 'Name' },
        { key: 'calorie_value', label: 'Calories' },
        { key: 'price', label: 'Price' },
        { key: 'taken_at', label: 'Taken at' },
        { key: 'actions', label: '' }
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
  },
  methods: {
    refreshTable (event) {
      this.$root.$emit('bv::refresh::table', 'foods-list')
    },
    fetchData (ctx) {
      let params = {
        'page[number]': this.currentPage,
        'page[size]': this.perPage,
        'filter[taken_at_gteq]': this.dayStartString(this.dateRange.startDate),
        'filter[taken_at_lteq]': this.dayEndString(this.dateRange.endDate)
      }

      let promise = this.plain.get(this.fetchFoodsPath || '/foods', {params})
      return promise.then(response => {
        this.cleanErrors()
        this.totalRows = response.data.meta.records
        return response.data.data.map(function (food) {
          return {
            id: food.id,
            food_name: food.attributes.name,
            calorie_value: food.attributes.calorie_value,
            price: food.attributes.price,
            taken_at: moment(food.attributes.taken_at).format('YYYY-MM-DD HH:mm:ss')
          }
        })
      }).catch(error => {
        this.serverErrors = this.parseServerErrors(error, 'Something went wrong during data fetching...')
        return []
      })
    },
    removeFood (item, index, button) {
      if (!this.isAdmin()) {
        return null
      }

      if (confirm(`Do you really want to delete food: ID: ${item.id}, Name ${item.name}?`)) {
        this.plain.delete(`/admin/foods/${item.id}`)
          .then(response => {
            this.cleanErrors()
            this.refreshTable()
          }).catch(error => {
            this.serverErrors = this.parseServerErrors(error, 'Something went wrong.')
          })
      }
    },
    updateFood (item, index, button) {
      if (this.isAdmin()) {
        this.$router.replace(`/foods/edit/${item.id}`)
      }
    },
    isAdmin () {
      return this.$store.getters.isAdmin
    },
    isAllProductsView () {
      return this.fetchFoodsPath === '/admin/foods'
    },
    cleanErrors () {
      this.serverErrors = []
    }
  },
  components: { AppHeader, DateRangePicker, ErrorAlert }
}
</script>

<style land="css">
  .clickable {
    cursor: pointer
  }
</style>
