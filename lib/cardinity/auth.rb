# frozen_string_literal: true

require 'base64'
require 'openssl'
require 'uri'
require 'cgi'

class Cardinity::Auth

  OAUTH_VERSION = '1.0'
  SIGNATURE_METHOD = 'HMAC-SHA1'

  def initialize(config)
    @config = config
  end

  def sign_request(method, uri, params = {})
    params = {
        oauth_consumer_key: @config[:key],
        oauth_nonce: generate_key,
        oauth_signature_method: SIGNATURE_METHOD,
        oauth_timestamp: generate_timestamp,
        oauth_version: OAUTH_VERSION
    }.update(params)
    params[:oauth_signature] = request_signature(method, uri, params)
    params_str = params.map { |k, v| "#{k}=\"#{escape(v.to_s)}\"" }.join(', ')
    "OAuth #{params_str}"
  end

  def request_signature(method, uri, params)
    base_str = generate_base_string(method, uri, params)
    encoded_digest(base_str)
  end

  def encoded_digest(string)
    Base64.strict_encode64(digest(string))
  end

  def digest(string)
    key = escape(@config[:secret]) + '&'
    OpenSSL::HMAC.digest(
        OpenSSL::Digest.new('sha1'),
        key,
        string)
  end

  def escape(string)
    URI.encode_www_form_component(string)
  end

  def generate_base_string(method, url, params)
    base = [method.to_s.upcase, url, normalized_params(params)]
    base.map { |v| escape(v) }.join('&')
  end

  private

    def generate_key(size=32)
      Base64.strict_encode64(OpenSSL::Random.random_bytes(size)).gsub(/\W/, '')
    end

    def generate_timestamp
      Time.now.to_i.to_s
    end

    def normalized_params(params)
      params.collect { |k, v| "#{k}=#{v}" }.sort.join("&")
    end

end
