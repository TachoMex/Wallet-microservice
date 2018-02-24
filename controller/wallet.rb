require './lib/dependency_injector'
require_relative 'transaction'

module Controller
  class Wallet
    extend DependencyInjector

    class << self
      def create
        table = resource(:database)
        time = Time.now
        id = table.insert(creation_date: time)
        new(id, time)
      end

      def find(id)
        table = resource(:database)
        data = table.where(wallet_id: id).first
        raise(WalletNotFound, id) if data.nil?
        new(data[:wallet_id], data[:creation_date])
      end
    end

    def initialize(id, creation)
      @id = id
      @creation = creation
      @dataset = self.class.resource(:database).where(wallet_id: id)
    end

    def receive_money(amount)
      raise(InvalidAmount, amount) if amount.negative?
      generate_transaction(amount)
    end

    def take_money(amount)
      raise(InvalidAmount, amount) if amount.negative?
      raise(InsufficientFounds, balance) if balance < amount
      generate_transaction(-amount)
    end

    def balance
      @balance ||= @dataset
                   .inner_join(:transaction, %i[wallet_id])
                   .sum(:amount) || 0
    end

    def transactions
      Transaction.transactions_by_wallet(@id)
    end

    private

    def generate_transaction(amount)
      transaction = Transaction.create(self, amount)
      @balance += amount
      transaction
    end
  end
end
