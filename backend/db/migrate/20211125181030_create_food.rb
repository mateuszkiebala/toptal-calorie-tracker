class CreateFood < ActiveRecord::Migration[6.0]
  def change
    create_table :foods do |t|
      t.string :name, null: false
      t.references :user, index: true, foreign_key: true
      t.decimal :calorie_value, precision: 10, scale: 2, null: false
      t.decimal :price, precision: 10, scale: 2, default: 0.0
      t.datetime :taken_at, null: false
      t.timestamps
    end
  end
end
