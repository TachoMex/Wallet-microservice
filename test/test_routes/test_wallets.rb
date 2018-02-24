require './test/test_helper'

class TestWallets < Minitest::Test
  include Rack::Test::Methods

  def app
    WalletService
  end

  def setup
    @database = Services.database
    @database.run('BEGIN;')
  end

  def teardown
    @database.run('ROLLBACK;')
  end

  def test_create_wallet
    post('/api/wallets')
    assert_equal(201, last_response.status)
    response = last_json_response
    assert_equal(response['status'], 'success')
    refute_nil(response['data'])
    refute_nil(response['data']['wallet_id'])
    assert_equal(0, response['data']['balance'])
    assert_equal(Time.now.to_s, response['data']['creation_date'])
    response['data']['wallet_id']
  end

  def test_receive_money
    wallet_id = test_create_wallet
    post("/api/wallets/#{wallet_id}/receive_money", amount: 100)
    response = last_json_response
    assert_equal(201, last_response.status)
    assert_equal(response['status'], 'success')
    assert_nil(response['data']['confirmation_date'])
    assert_equal(response['data']['wallet_id'], wallet_id)
    ap(response)
  end

  def test_receive_money_float
    wallet_id = test_create_wallet
    post("/api/wallets/#{wallet_id}/receive_money", amount: 100.2324)
    response = last_json_response
    assert_equal(201, last_response.status)
    assert_equal(response['status'], 'success')
    assert_nil(response['data']['confirmation_date'])
    assert_equal(response['data']['wallet_id'], wallet_id)
    ap(response)
  end

  def test_fail_receive_money
    wallet_id = test_create_wallet
    post("/api/wallets/#{wallet_id}/receive_money", amount: -100)
    response = last_json_response
    assert_equal(response['status'], 'fail')
    ap(response)
  end

  def test_fatal_receive_money
    post("/api/wallets/-1/receive_money", amount: -100)
    response = last_json_response
    ap(response)
    assert_equal(response['status'], 'fail')
  end
  
  def test_take_wallet
    id = test_create_wallet
    post("api/wallets/#{id}/receive_money",amount: 50)
    assert_equal(201,last_response.status)
    post("api/wallets/#{id}/take_money", amount: 20)
    response = last_json_response
    assert_equal('success',response['status'])
    refute_nil(response['data'])
    refute_nil(response['data']['amount'])
    ap response
    assert_equal(-20, response['data']['amount'])
  end
end
