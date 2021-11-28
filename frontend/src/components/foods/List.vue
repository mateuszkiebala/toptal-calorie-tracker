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

export default {
  name: 'List',
  data () {
    return {
      error: '',
      isBusy: false,
      fields: [
        { key: 'id', label: 'ID' },
        { key: 'food_name', label: 'Name' },
        { key: 'calorie_value', label: 'Calories' },
        { key: 'price', label: 'Price' },
        { key: 'taken_at', label: 'Taken at' }
      ],
      totalRows: 0,
      currentPage: 1,
      perPage: 10,
      pageOptions: [5, 10, 15, { value: 100, text: 'Show a lot' }]
    }
  },
  methods: {
    setError (error, text) {
      this.error = (error.response.errors[0] && error.response.errors[0].detail) || text
    },
    fetchData (ctx) {
      if (!this.$store.getters.signedIn) {
        this.$router.replace('/')
      } else {
        let params = {
          'page[number]': this.currentPage,
          'page[size]': this.perPage
        }

        let promise = this.plain.get('/foods', {params})
        return promise.then(response => {
          this.totalRows = response.data.meta.records
          return response.data.data.map(function (food) {
            return Object.assign({}, food.attributes, {id: food.id, food_name: food.attributes.name})
          })
        }).catch(error => {
          this.setError(error, 'Something went wrong')
          return []
        })
      }
    }
  },
  components: { AppHeader }
}
</script>

<style lang="css">
  @import '../../assets/styles/vue-formulate.css';
  .foods ul li i.fa.fa-trash-alt {
    visibility: hidden;
    margin-top: 5px;
  }
  .foods ul li:hover {
    background: #fcfcfc;
  }
  .foods ul li:hover i.fa.fa-trash-alt {
    visibility: visible;
  }
</style>
