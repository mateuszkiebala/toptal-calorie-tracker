class CreateUser < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :username,   null: false
      t.string :auth_token, null: true
      t.integer :role,      null: false,   default: 0
      t.timestamps
    end

    add_index :users, [:username], unique: true
    add_index :users, [:auth_token], unique: true
  end
end
