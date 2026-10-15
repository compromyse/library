class AddCreatedAtIndexToInteractions < ActiveRecord::Migration[8.1]
  def change
    add_index :interactions, :created_at
  end
end
