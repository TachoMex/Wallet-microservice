Sequel.migration do
  up do
    create_table(:transaction) do
      primary_key :transaction_id, auto_increment: true
      foreign_key :wallet_id, :wallet
      Double      :amount, null: false
      DateTime    :entry_date, null: false, default: :now.sql_function
      DateTime    :confirmation_date, default: nil
      String      :status, size: 10, null: false, default: 'pending'
    end
  end
end
