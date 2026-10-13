class CreateServicePlans < ActiveRecord::Migration[8.1]
  def change
    create_table :service_plans do |t|
      t.string :client_name, null: false
      t.string :contact
      t.date :date_of_contact, null: false
      t.text :background

      t.timestamps
    end
  end
end
