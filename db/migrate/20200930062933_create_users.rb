class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :password_digest
      t.string :icon_url
      t.text :description
      t.timestamps null: false
    end
  end
end
