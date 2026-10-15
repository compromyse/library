class ConvertUserApprovedToStatusEnum < ActiveRecord::Migration[8.1]
  # status: pending = 0, approved = 1, denied = 2
  def up
    add_column :users, :status, :integer, default: 0, null: false
    execute "UPDATE users SET status = CASE WHEN approved THEN 1 ELSE 0 END"
    remove_column :users, :approved
    add_index :users, :status
  end

  def down
    add_column :users, :approved, :boolean, default: false, null: false
    execute "UPDATE users SET approved = (status = 1)"
    remove_column :users, :status
  end
end
