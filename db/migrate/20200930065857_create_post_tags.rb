class CreatePostTags < ActiveRecord::Migration[5.2]
  def change
    create_table :posttags do |t|
      t.integer :post_id
      t.integer :tag_id
      t.timestamps null: false
    end
  end
end
