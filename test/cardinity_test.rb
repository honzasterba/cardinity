# frozen_string_literal: true

require 'test_helper'

class CardinityTest < Minitest::Test

  def setup
    env_key = ENV["CRD_KEY"]
    assert env_key, "Environment variables CRD_KEY and CRD_SECRET required. (CRD_KEY missing)"
    env_secret = ENV["CRD_SECRET"]
    assert env_secret, "Environment variables CRD_KEY and CRD_SECRET required. (CRD_SECRET missing)"
    Cardinity.configure! key: env_key, secret: env_secret
    @payment_data = {
      amount: 11,
      currency: "EUR",
      country: "CZ",
      payment_method: "card",
      payment_instrument: {
          pan: VISA_1,
          exp_year: 2018,
          exp_month: 11,
          cvc: 123,
          holder: "John Doe"
      }
    }
  end

  def test_that_it_has_a_version_number
    refute_nil ::Cardinity::VERSION
  end

  def test_fetch_list_of_payments
    assert Cardinity.payments.is_a?(Array)
  end

  def test_fetch_payment
    payment_id = Cardinity.create_payment(@payment_data)['id']
    assert_equal Cardinity.payment(payment_id)['id'], payment_id
  end

  def test_refund
    payment_id = Cardinity.create_payment(@payment_data)['id']
    create_refund_response = Cardinity.create_refund(
      payment_id, amount: @payment_data[:amount], description: 'test refund'
    )
    assert_equal create_refund_response['description'], 'test refund'
    refund_id = create_refund_response['id']
    assert_equal Cardinity.refund(payment_id, refund_id)['id'], refund_id
    assert_equal Cardinity.refunds(payment_id)[0]['id'], refund_id
  end

  VISA_1 = "4111111111111111"

  VISA_2 = "4222222222222"

  MASTERCARD = "5555555555554444"

  def test_successful_payment
    result = Cardinity.create_payment @payment_data
    assert_equal  Cardinity::TYPE_PURCHASE, result["type"], result
    assert result["id"], result
    assert_equal "11.00", result["amount"], result
    assert_equal Cardinity::STATUS_APPROVED, result["status"], result
  end

  def test_declined_payment
    @payment_data[:amount] = 200
    result = Cardinity.create_payment @payment_data
    assert Cardinity::STATUS_DECLINED, result["status"]
  end

  def test_fail_wrong_pan
    @payment_data[:payment_instrument][:pan] = "4242424242424241"
    result = Cardinity.create_payment @payment_data
    assert result["type"].start_with?(Cardinity::TYPE_ERROR)
  end

  def test_fail_wrong_exp
    @payment_data[:payment_instrument][:exp_month] = "14"
    result = Cardinity.create_payment @payment_data
    assert result["type"].start_with?(Cardinity::TYPE_ERROR)
  end

  def test_3d_success
    @payment_data[:description] = "3d-pass"
    result = Cardinity.create_payment @payment_data
    assert_equal Cardinity::STATUS_PENDING, result["status"], result
    assert result["authorization_information"], result
    patch_result = Cardinity.finalize_payment(result["id"], authorize_data: "3d-pass")
    assert_equal result["id"], patch_result["id"], patch_result
    assert_equal Cardinity::STATUS_APPROVED, patch_result["status"]
  end

  def test_3d_fail
    @payment_data[:description] = "3d-fail"
    result = Cardinity.create_payment @payment_data
    assert_equal Cardinity::STATUS_PENDING, result["status"], result
    assert result["authorization_information"], result
    patch_result = Cardinity.finalize_payment(result["id"], authorize_data: "3d-fail")
    assert_equal result["id"], patch_result["id"], patch_result
    assert_equal Cardinity::STATUS_DECLINED, patch_result["status"]
  end

end
