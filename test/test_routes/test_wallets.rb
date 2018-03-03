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

  def assert_jsend_status(status = 'success')
    response = last_json_response
    assert_equal(response['status'], status)
    refute_nil(response['data'])
    assert_equal(2, last_response.status / 100)
    response['data']
  end

  def test_create_wallet
    post('/api/wallets')
    response = assert_jsend_status
    refute_nil(response['wallet_id'])
    assert_equal(0, response['balance'])
    assert_equal(Time.now.to_s, response['creation_date'])
    response['wallet_id']
  end

  def test_receive_money
    wallet_id = test_create_wallet
    post("/api/wallets/#{wallet_id}/receive_money", amount: 100)

    response = assert_jsend_status
    assert_nil(response['confirmation_date'])
    assert_equal(response['wallet_id'], wallet_id)
  end

  def test_receive_money_float
    wallet_id = test_create_wallet
    post("/api/wallets/#{wallet_id}/receive_money", amount: 100.2324)

    response = assert_jsend_status
    assert_nil(response['confirmation_date'])
    assert_equal(response['wallet_id'], wallet_id)
  end

  def test_fail_receive_money
    wallet_id = test_create_wallet
    post("/api/wallets/#{wallet_id}/receive_money", amount: -100)
    assert_jsend_status('fail')
  end

  def test_fatal_receive_money
    post('/api/wallets/-1/receive_money', amount: 100)
    assert_jsend_status('fail')
  end

  def test_take_money
    id = test_create_wallet
    post("api/wallets/#{id}/receive_money", amount: 50)
    post("api/wallets/#{id}/take_money", amount: 20)
    response = assert_jsend_status
    assert_equal(-20, response['amount'])

    get("api/wallets/#{id}")
    data = assert_jsend_status
    assert_equal(data['balance'], 30)
  end

  def test_take_money_not_enough
    id = test_create_wallet
    post("api/wallets/#{id}/take_money", amount: 20)
    assert_jsend_status('error')
  end
end
