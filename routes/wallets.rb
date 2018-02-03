require 'grape'

require './controller/wallet'

module Routes
  class Wallets < Grape::API
    namespace :wallets do
      post do
      end

      route_param :wallet_id do
        get do
        end

        post :take_money do
        end

        post :receive_money do
        end
      end
    end
  end
end
