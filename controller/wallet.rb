require './lib/dependency_injector'
require_relative 'transaction'

module Controller
  class Wallet
    extend DependencyInjector
    attr_reader :id
    class InvalidAmount < Ant::Exceptions::AntFail
      def initialize(amount)
        super('the amount is not valid', nil, amount: amount)
      end
    end
    class InsufficientFounds < Ant::Exceptions::AntError
      def initialize(balance, amount)
        super('the amount is more than the balance', nil, balance: balance, amount: amount)
      end
    end
    class WalletNotFound < Ant::Exceptions::AntFail
      def initialize(id)
        super('wallet id not send', nil, id: id)
      end
    end

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
      raise(InsufficientFounds.new(balance, amount)) if balance < amount
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

    def to_json(options)
      {
        wallet_id: @id,
        creation_date: @creation,
        balance: balance
      }.to_json(options)
    end

    private

    def generate_transaction(amount)
      transaction = Transaction.create(self, amount)
      balance # make @balance be initialized
      @balance += amount
      transaction
    end
  end
end
