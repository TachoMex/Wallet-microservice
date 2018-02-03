require 'grape'

require './controller/wallet'

module Routes
  class Wallets < Grape::API
    namespace :wallets do
      post do
        Controller::Wallet.create
      end

      route_param :wallet_id do
        get do
          Controller::Wallet.find(params[:wallet_id])
        end

        post :take_money do
          wallet = Controller::Wallet.find(params[:wallet_id])
          wallet.take_money(params[:amount])
        end

        post :receive_money do
          wallet = Controller::Wallet.find(params[:wallet_id])
          wallet.receive_money(params[:amount])
        end
      end
    end
  end
end
