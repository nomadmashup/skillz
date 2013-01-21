class CreateSkillsModels < ActiveRecord::Migration

  def change

    create_table :users do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :project
      t.timestamps
    end
    add_index :users, :email
    add_index :users, :project

    create_table :skills do |t|
      t.string :code
      t.string :label
      t.text :description
      t.string :parent
      t.integer :sort_order
      t.timestamps
    end
    add_index :skills, :code

    create_table :dimensions do |t|
      t.string :code
      t.string :label
      t.text :description
      t.integer :sort_order
      t.timestamps
    end
    add_index :dimensions, :code

    create_table :dimension_options do |t|
      t.integer :dimension_id
      t.string :short_label
      t.string :long_label
      t.text :description
      t.integer :sort_order
      t.string :value
      t.timestamps
    end
    add_index :dimension_options, :dimension_id

    create_table :skill_details do |t|
      t.integer :user_id
      t.integer :skill_id
      t.integer :dimension_id
      t.string :value
      t.timestamps
    end
    add_index :skill_details, :user_id
    add_index :skill_details, :skill_id
    add_index :skill_details, :dimension_id

    say "Sweet!"

  end

end
