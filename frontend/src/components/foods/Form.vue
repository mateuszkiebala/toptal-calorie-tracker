<template>
  <div>
    <AppHeader></AppHeader>

    <h3 v-if="this.$route.params.id">Update product</h3>
    <h3 v-else>Create new product</h3>

    <div class="container">
      <h3 v-if="!noServerErrors()">Errors</h3>
      <ul class="errors">
        <li v-for="error in errors" :key="error" :error="error">
          <b-alert variant="danger" show>{{ error }}</b-alert>
        </li>
      </ul>
    </div>

    <b-form class="form-food" @submit="onSubmit" @reset="onReset" v-if="show">
      <b-form-group id="input-group-name" label="Name:" label-for="input-name">
        <b-form-input
          id="input-name"
          v-model="$v.form.name.$model"
          :state="validateState('name')"
          aria-describedby="input-name-live-feedback"
          placeholder="What is product name?"
        ></b-form-input>

        <b-form-invalid-feedback id="input-name-live-feedback">
          This is a required field. Must be 3-100 characters long, can contain only letters, digits and spaces.
        </b-form-invalid-feedback>
      </b-form-group>

      <b-form-group id="input-group-calories" label="Calorie value:" label-for="input-calories">
        <b-form-input
          id="input-calories"
          v-model="$v.form.calorie_value.$model"
          :state="validateState('calorie_value')"
          aria-describedby="input-calories-live-feedback"
          placeholder="How much calories does this product contain?"
        ></b-form-input>

        <b-form-invalid-feedback id="input-calories-live-feedback">
          This is a required field. Must be a real number in range 0-10000.
        </b-form-invalid-feedback>
      </b-form-group>

      <b-form-group id="input-group-price" label="Price ($):" label-for="input-price">
        <b-form-input
          id="input-price"
          v-model="$v.form.price.$model"
          :state="validateState('price')"
          aria-describedby="input-price-live-feedback"
          placeholder="How much did you pay for this product?"
        ></b-form-input>

        <b-form-invalid-feedback id="input-price-live-feedback">
          This is a required field. Must be a real number bigger or equal 0.
        </b-form-invalid-feedback>
      </b-form-group>

      <b-form-group id="input-group-taken-day" label="Consumption day:" label-for="taken-day">
        <b-form-datepicker
          id="taken-day"
          menu-class="w-100"
          calendar-width="100%"
          class="mb-2"
          today-button
          reset-button
          close-button
          v-model="$v.form.taken_at_day.$model"
          :state="validateState('taken_at_day')"
          aria-describedby="input-taken-day-live-feedback"
          placeholder="What day did you eat this product?"
        ></b-form-datepicker>

        <b-form-invalid-feedback id="input-taken-day-live-feedback">
          This is a required field.
        </b-form-invalid-feedback>
      </b-form-group>

      <b-form-group id="input-group-taken-time" label="Consumption time:" label-for="taken-time">
        <b-form-timepicker
          id="taken-time"
          now-button
          reset-button
          locale="en"
          v-model="$v.form.taken_at_time.$model"
          :state="validateState('taken_at_time')"
          aria-describedby="input-taken-time-live-feedback"
          placeholder="What time did you eat this product?"
        ></b-form-timepicker>

        <b-form-invalid-feedback id="input-taken-time-live-feedback">
          This is a required field.
        </b-form-invalid-feedback>
      </b-form-group>

      <b-button type="submit" variant="primary">Submit</b-button>
      <b-button type="reset" variant="danger">Reset</b-button>
    </b-form>
  </div>
</template>

<script>
import AppHeader from '@/components/AppHeader'
import { validationMixin } from 'vuelidate'
import { required, minLength, maxLength, helpers, between, minValue } from 'vuelidate/lib/validators'
import moment from 'moment'

export default {
  name: 'Form',
  mixins: [validationMixin],
  data () {
    return {
      errors: [],
      food_id: null,
      form: {
        name: null,
        calorie_value: null,
        price: null,
        taken_at_day: null,
        taken_at_time: null
      },
      show: true
    }
  },
  created () {
    this.setFoodId()
    this.fillWithData()
  },
  validations: {
    form: {
      name: {
        required,
        minLength: minLength(3),
        maxLength: maxLength(100),
        isNameValid: helpers.regex('isNameValid', /^[a-zA-Z0-9\s]*$/i)
      },
      calorie_value: {
        required,
        between: between(0, 10000)
      },
      price: {
        required,
        minValue: minValue(0)
      },
      taken_at_day: {
        required
      },
      taken_at_time: {
        required
      }
    }
  },
  methods: {
    setFoodId () {
      this.food_id = this.$route.params.id
    },
    validateState (name) {
      const { $dirty, $error } = this.$v.form[name]
      return $dirty ? !$error : null
    },
    noServerErrors () {
      return this.errors == null || this.errors.length === 0
    },
    setError (serverErrors, text) {
      let messages = serverErrors.response.data.errors.map(function (error) {
        return error.detail
      })
      this.errors = messages || [text]
    },
    onSubmit (event) {
      event.preventDefault()

      this.$v.form.$touch()
      if (this.$v.$invalid) {
        return
      }

      if (this.food_id) {
        this.updateFood()
      } else {
        this.createFood()
      }
    },
    onReset (event) {
      event.preventDefault()

      this.form = {
        name: null,
        calorie_value: null,
        price: null,
        taken_at_day: null,
        taken_at_time: null
      }
      this.errors = []

      this.$nextTick(() => {
        this.$v.$reset()
      })

      // Trick to reset/clear native browser form validation state
      this.show = false
      this.$nextTick(() => {
        this.show = true
      })
    },
    getFoodAttributes () {
      return {
        type: 'foods',
        attributes: {
          name: this.form.name,
          calorie_value: this.form.calorie_value,
          price: this.form.price,
          taken_at: `${this.form.taken_at_day}T${this.form.taken_at_time}`
        }
      }
    },
    createFood () {
      let data = this.getFoodAttributes()
      this.plain.post('/foods', { data })
        .then(response => {
          this.$router.replace('/dashboard')
        }).catch(error => {
          this.setError(error, 'Something went wrong')
        })
    },
    updateFood () {
      if (this.isAdmin() && this.food_id) {
        let data = this.getFoodAttributes()
        this.plain.patch(`/admin/foods/${this.food_id}`, { data })
          .then(response => {
            this.$router.replace('/dashboard')
          }).catch(error => {
            this.setError(error, 'Something went wrong')
          })
      }
    },
    fillWithData () {
      if (this.isAdmin() && this.food_id) {
        this.plain.get(`/foods/${this.food_id}`)
          .then(response => {
            let foodAttributes = response.data.data.attributes
            this.form.name = foodAttributes.name
            this.form.calorie_value = foodAttributes.calorie_value
            this.form.price = foodAttributes.price
            this.form.taken_at_day = moment(foodAttributes.taken_at).format('YYYY-MM-DD')
            this.form.taken_at_time = moment(foodAttributes.taken_at).format('hh:mm')
            this.$v.form.$touch()
          }).catch(error => {
            this.setError(error, 'Something went wrong')
          })
      }
    },
    isAdmin () {
      return this.$store.getters.isAdmin
    }
  },
  components: { AppHeader }
}
</script>

<style lang="css">
  .form-food {
    width: 70%;
    max-width: 500px;
    padding: 10% 15px;
    margin: 0 auto;
  }
  ul.errors {
    list-style-type: none;
    margin: 0;
    padding: 0;
  }
</style>
