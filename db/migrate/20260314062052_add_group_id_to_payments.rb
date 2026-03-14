class AddGroupIdToPayments < ActiveRecord::Migration[8.1]
  def change
    add_column :payments, :group_id, :string
  end
end
