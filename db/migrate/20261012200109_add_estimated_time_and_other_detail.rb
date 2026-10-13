class AddEstimatedTimeAndOtherDetail < ActiveRecord::Migration[8.1]
  def change
    add_column :interactions, :estimated_time, :integer, null: false
    add_column :issues, :primary_need_other_detail, :text
  end
end
