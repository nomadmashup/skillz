class RemoveColumnsFromSkill < ActiveRecord::Migration
  def change
    change_table :skills do |t|
      t.remove :top_parent
      t.remove :depth
    end
  end
end
