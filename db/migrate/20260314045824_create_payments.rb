class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.string :line_user_id
      t.integer :amount

      t.timestamps
    end
  end
end
