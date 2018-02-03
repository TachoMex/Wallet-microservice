require 'grape'

require './controller/wallet'

module Routes
  class Transactions < Grape::API
    namespace :wallets do
      route_param :wallet_id do
        namespace :transactions do
          get do
          end
        end
      end
    end

    namespace :transactions do
      route_param :transaction_id do
        post :cofirm do
        end
      end
    end
  end
end
