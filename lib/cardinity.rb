# frozen_string_literal: true

require 'cardinity/version'
require 'cardinity/utils'
require 'cardinity/auth'
require 'rest-client'
require 'json'

module Cardinity

  DEFAULT_API_BASE = 'https://api.cardinity.com/v1/'

  API_PAYMENTS = 'payments'

  STATUS_PENDING = 'pending'
  STATUS_APPROVED = 'approved'
  STATUS_DECLINED = 'declined'

  TYPE_AUTHORIZATION = 'authorization'
  TYPE_PURCHASE = 'purchase'
  TYPE_ERROR = 'https://developers.cardinity.com/api/v1/'

  # Configure Cardinity. Must be called before other methods.
  #
  # @param [Hash] options
  # @option options [String] :key API key.
  # @option options [String] :secret API secret.
  # @option options [String] :api_base (DEFAULT_API_BASE) API base URL.
  def self.configure!(options)
    @config = {
        # key and secret to be supplied from outside
        api_base: DEFAULT_API_BASE
    }
    @config.merge! options
    @auth = Cardinity::Auth.new(@config)
  end

  # Creates a Payment object
  #
  # @param [Hash] payment_hash Payment data. Keys can be symbols or strings.
  # @option payment_hash [Numeric, String] :amount #0.00.
  #   If a string, two decimals are required.
  # @option payment_hash [String] :currency Three-letter ISO currency code,
  #   e.g. "EUR".
  # @option payment_hash [Boolean] :settle (true) If false, creates a
  #   pre-authorization instead of settling immediately.
  # @option payment_hash [String] :country Customer's billing country as
  #   ISO 3166-1 alpha-2 country code, required.
  # @option payment_hash [String] :payment_method ('card')
  # @option payment_hash [Hash] :payment_instrument Card details:
  #   * :pan [String] Card number.
  #   * :exp_year [Integer] 4-digit year.
  #   * :exp_month [Integer] 2-digit month
  #   * :cvc [Integer] Card security code.
  #   * :holder [String] Cardholder's name, max length 32 characters.
  # @option payment_hash [String, nil] :order_id (nil)
  # @option payment_hash [String, nil] :description (nil)
  # @return [Hash] Updated payment object or an error object.
  def self.create_payment(payment_hash)
    checked_payment_data = check_payment_data(payment_hash)
    parse post(payments_uri, serialize(checked_payment_data))
  end

  # Finalizes a Payment
  #
  # This is necessary for 3D secure payments, when the customer has completed
  # the 3D secure redirects and authorization.
  #
  # @param [String] payment_id
  # @param [String] authorize_data PaRes string received from 3D secure.
  # @return [Hash] Payment or error object.
  def self.finalize_payment(payment_id, authorize_hash)
    parse patch(payment_uri(payment_id), serialize(authorize_hash))
  end

  # Get list of the last payments.
  # By default, cardinity returns 10 payments. Pass `limit` to override.
  # @param [Integer, nil] limit
  # @return [Array<Hash>, Hash] Payment objects or an error object.
  def self.payments(limit: nil)
    query = {}
    query[:limit] = limit if limit
    parse get(payments_uri, query)
  end

  # Get the payment information for the given payment ID.
  # @param [String] payment_id
  # @return [Hash] Payment or error object.
  def self.payment(payment_id)
    parse get(payment_uri(payment_id))
  end

  # Fully or partially refund a payment
  # @param [String] payment_id
  # @param [Numeric, String] amount If a string, two decimals are required.
  # @param [String] description
  # @return [Hash] Refund or error object.
  def self.create_refund(payment_id, amount:, description: '')
    amount = format('%.2f', amount) if amount.is_a?(Numeric)
    parse post(refunds_uri(payment_id),
               serialize(amount: amount, description: description))
  end

  # Get all the refunds for the given payment ID.
  # @param [String] payment_id
  # @return [Array<Hash>, Hash] Refund objects or an error object.
  def self.refunds(payment_id)
    parse get(refunds_uri(payment_id))
  end

  # Get the refund for the given payment ID and refund ID.
  # @param [String] payment_id
  # @param [String] refund_id
  # @return [Hash] Refund or error object.
  def self.refund(payment_id, refund_id)
    parse get(refund_uri(payment_id, refund_id))
  end
end
