class CreateInteractions < ActiveRecord::Migration[8.1]
  def change
    create_table :interactions do |t|
      t.integer :age, null: false
      t.integer :gender, null: false

      t.timestamps
    end
  end
end
