require './lib/dependency_injector'
require_relative 'transaction'

module Controller
  class Wallet
    extend DependencyInjector

    class << self
      def create
      end

      def find(id)
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
