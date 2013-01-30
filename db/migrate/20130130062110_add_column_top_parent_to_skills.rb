class AddColumnTopParentToSkills < ActiveRecord::Migration
  def change
    change_table :skills do |t|
      t.string :top_parent
    end
  end
end
