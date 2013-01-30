class AddAdditionalColumns < ActiveRecord::Migration
  def change
    change_table :skills do |t|
      t.string :parents
      t.integer :depth
    end
  end
end
