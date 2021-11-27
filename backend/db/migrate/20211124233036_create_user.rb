class CreateUser < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :username,   null: false
      t.string :auth_token, null: true
      t.integer :role,      null: false,   default: 0
      t.decimal :calorie_limit, precision: 15, scale: 2, default: 2100.0
      t.decimal :money_limit, precision: 15, scale: 2, default: 1000.0
      t.timestamps
    end

    add_index :users, [:username], unique: true
    add_index :users, [:auth_token], unique: true
  end
end
