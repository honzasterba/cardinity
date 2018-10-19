require 'test_helper'

class AuthTest < Minitest::Test

  def setup
    @auth = Cardinity::Auth.new(key: "test_key", secret: "test_secret")
  end

  def test_escape
    assert_equal "just+test%2Bdata*", @auth.escape("just test+data*")
  end

  def test_signature
    auth = Cardinity::Auth.new(secret: "yvp0leodf231ihv9u29uuq6w8o4cat9qz2nkvs55oeu833s621")
    assert_equal "PxkffxyQh6jsDNcgJ23GpAxs2y8=", auth.encoded_digest("justsomerandommessage")
  end

  BASE_STRING = "GET&http%3A%2F%2Fapi.example.com&oauth_consumer_key%3Dtest_key%26" +
      "oauth_nonce%3D2ba5d0a6ae6e7456%26oauth_signature_method%3DHMAC-SHA1%26" +
      "oauth_timestamp%3D1484176149%26oauth_version%3D1.0"

  HOST = "http://api.example.com"

  PARAMS = {
      oauth_consumer_key: "test_key",
      oauth_nonce: "2ba5d0a6ae6e7456",
      oauth_signature_method: "HMAC-SHA1",
      oauth_timestamp: "1484176149",
      oauth_version: "1.0"
  }

  SIGNATURE = "dwIZ/A+88Ee40sNonuumj/U/ICU="

  def test_base_string
    assert_equal BASE_STRING, @auth.generate_base_string(:get, HOST, PARAMS)
  end

  def test_sign_base_string
    assert_equal SIGNATURE, @auth.encoded_digest(BASE_STRING)
  end

  def test_sign_params
    assert_equal SIGNATURE, @auth.request_signature(:get, HOST, PARAMS)
  end

end
