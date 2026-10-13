class CreateServicePlanInteractions < ActiveRecord::Migration[8.1]
  def change
    create_table :service_plan_interactions do |t|
      t.references :service_plan, null: false, foreign_key: true
      t.date :date, null: false
      t.integer :primary_need, null: false
      t.text :primary_need_other_detail
      t.text :action_referrals, null: false
      t.references :point_person, foreign_key: { to_table: :users }
      t.string :point_person_name
      t.integer :status, null: false, default: 0
      t.text :notes

      t.timestamps
    end
  end
end
