require 'cute_logger'
require 'sequel'
require 'puma'
require 'ant'

require_relative 'lib/services'
require_relative 'routes/wallets'
require_relative 'routes/transactions'

class WalletService < Grape::API
  Controller::Wallet.register(:database, Services.database[:wallet])
  Controller::Transaction.register(:database, Services.database[:transaction])

  version('v1', using: :header, vendor: :cut)
  prefix(:api)
  format(:json)

  helpers Ant::Response
  mount Routes::Wallets
  mount Routes::Transactions
end
