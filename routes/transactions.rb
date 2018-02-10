require 'grape'

require './controller/wallet'

Services.configure!

module Routes
  class Transactions < Grape::API
    namespace :wallets do
      route_param :wallet_id do
        namespace :transactions do
          get do
            process_request do
              Controller::Transaction.transactions_by_wallet(params[:wallet_id])
            end
          end
        end
      end
    end

    namespace :transactions do
      route_param :transaction_id do
        post :confirm do
          process_request do
            transaction = Controller::Transaction.find(params[:transaction_id])
            transaction.commit
            transaction
          end
        end
      end
    end
  end
end
