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

    def receive_money(amout)
      generate_transaction(amout)
    end

    def take_money(amount)
      generate_transaction(-amount)
    end

    def balance(amount)
    end

    def transactions
    end

    private

    def generate_transaction(amount)
    end
  end
end
