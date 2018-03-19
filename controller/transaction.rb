module Controller
  class Transaction
    extend Ant::DRY::ResourceInjector
    class << self
      def create(wallet, amount)
        db = resource(:database)
        time = Time.now
        id = db.insert(wallet_id: wallet.id, amount: amount, entry_date: time)
        new(wallet.id, id, amount, time)
      end

      def find(id)
        data = resource(:database).where(transaction_id: id).first
        raise(TransactionNotFound, id) if data.nil?
        from_database_record(data)
      end

      def transactions_by_wallet(id)
        resource(:database)
          .where(wallet_id: id)
          .map { |data| from_database_record(data) }
      end

      private

      def from_database_record(data)
        new(data[:wallet_id], data[:transaction_id], data[:amount],
            data[:entry_date], data[:confirmation_date])
      end
    end

    def initialize(wallet_id, id, amount, entry_date, confirmation_date = nil)
      @wallet_id = wallet_id
      @id = id
      @entry_date = entry_date
      @amount = amount
      @confirmation_date = confirmation_date
      @dataset = self.class.resource(:database).where(transaction_id: id)
    end

    def commit
      @confirmation_date = Time.now
      @dataset.update(confirmation_date: @confirmation_date)
    end

    def to_json(options)
      {
        transaction_id: @id,
        wallet_id: @wallet_id,
        entry_date: @entry_date,
        amount: @amount,
        confirmation_date: @confirmation_date
      }.to_json(options)
    end
  end
end
