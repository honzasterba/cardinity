# frozen_string_literal: true

require 'uri'

module Cardinity

  CODES_WITH_RESPONSE = [200, 201, 202, 400, 401, 402, 405, 500, 503]

  def self.check_payment_data(payment)
    payment = payment.dup
    payment_method = payment['payment_method'] || payment[:payment_method]
    if payment_method.nil?
      payment['payment_method'] = 'card'
    end
    amount = payment['amount'] || payment[:amount]
    if amount.is_a?(Numeric)
      payment.delete(:amount)
      payment['amount'] = format('%.2f', amount)
    end
    payment
  end

  def self.payments_uri
    "#{api_base}#{API_PAYMENTS}"
  end

  def self.payment_uri(payment_id)
    "#{api_base}#{API_PAYMENTS}/#{payment_id}"
  end

  def self.refunds_uri(payment_id)
    "#{api_base}#{API_PAYMENTS}/#{payment_id}/refunds"
  end

  def self.refund_uri(payment_id, refund_id)
    "#{api_base}#{API_PAYMENTS}/#{payment_id}/refunds/#{refund_id}"
  end

  def self.parse(response)
    JSON.parse response.body
  end

  def self.serialize(data)
    JSON.generate(data)
  end

  def self.handle_error_response(e)
    if CODES_WITH_RESPONSE.index e.response.code
      e.response
    else
      raise e
    end
  end

  def self.get(base_url, params = {})
    uri = URI.parse(base_url)
    uri.query = URI.encode_www_form(params)
    RestClient.get uri.to_s, headers(:get, base_url, params)
  rescue RestClient::ExceptionWithResponse => e
    handle_error_response e
  end

  def self.post(uri, body)
    RestClient.post uri, body, headers(:post, uri)
  rescue RestClient::ExceptionWithResponse => e
    handle_error_response e
  end

  def self.patch(uri, body)
    RestClient.patch uri, body, headers(:patch, uri)
  rescue RestClient::ExceptionWithResponse => e
    handle_error_response e
  end

  def self.headers(method, uri, params = {})
    {
        content_type: 'application/json',
        authorization: @auth.sign_request(method, uri, params)
    }
  end

  def self.api_base
    @config[:api_base]
  end

end
