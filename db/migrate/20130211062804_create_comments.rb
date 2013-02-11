class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.text :text
      t.string :action
      t.string :category

      t.timestamps
    end
  end
end
