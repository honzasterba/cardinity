module Cardinity

  CODES_WITH_RESPONSE = [200, 201, 202, 400, 402]

  def self.check_payment_data(payment)
    payment = payment.dup
    if payment[:payment_method].nil?
      payment[:payment_method] = 'card'
    end
    if payment[:amount].is_a?(Numeric)
      payment[:amount] = '%.2f' % payment[:amount]
    end
    payment
  end

  def self.payments_uri
    "#{api_base}#{API_PAYMENTS}"
  end

  def self.payment_uri(payment_id)
    "#{api_base}#{API_PAYMENTS}/#{payment_id}"
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

  def self.get(uri)
    RestClient.get uri, headers(:get, uri)
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

  def self.headers(method, uri)
    {
        content_type: 'application/json',
        authorization: @auth.sign_request(method, uri)
    }
  end

  def self.api_base
    @config[:api_base]
  end

end