Sequel.migration do
  up do
    create_table(:wallet) do
      primary_key :wallet_id, auto_increment: true
      DateTime :creation_date, null: false
    end
  end
end
