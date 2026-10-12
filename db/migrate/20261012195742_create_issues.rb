class CreateIssues < ActiveRecord::Migration[8.1]
  def change
    create_table :issues do |t|
      t.integer :primary_need, null: false
      t.text :interaction_description, null: false
      t.references :interaction, null: false, foreign_key: true

      t.timestamps
    end
  end
end
