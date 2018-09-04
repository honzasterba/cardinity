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

  def self.configure!(options)
    @config = {
        # key and secret to be supplied from outsite
        api_base: DEFAULT_API_BASE
    }
    @config.merge! options
    @auth = Cardinity::Auth.new(@config)
  end

  # Creates a Payment object
  #
  # Accepted attributes:
  # - amount (#0.00, two decimals required)
  # - currency (EUR,USD)
  # - settle (boolean, default true, false means just pre-authorize and finish later)
  # - order_id (not required)
  # - description (not required)
  # - country (country of customer, required)
  # - payment_method (required, only supported value is card)
  # - payment_instrument (card details)
  #   - pan (card number)
  #   - exp_year
  #   - exp_month
  #   - cvc
  #   - holder
  #
  # Returns:
  # - updated payment object on success
  # - error object on error
  def self.create_payment(payment_hash)
    checked_payment_data = check_payment_data(payment_hash)
    parse post(payments_uri, serialize(checked_payment_data))
  end

  # Finalizes a Payment
  #
  # This is necessary for 3D secure payments, when the customer has completed
  # the 3D secure redirects and authorization.
  #
  # Accepted attributes:
  #  - authorize_data (PaRes string received from 3D secure)
  #
  # Returns:
  # - updated payment object on success
  # - error object on error
  def self.finalize_payment(payment_id, authorize_hash)
    parse patch(payment_uri(payment_id), serialize(authorize_hash))
  end

  # Get list of the last payments.
  # By default, cardinity returns 10 payments. Pass `limit` to override.
  def self.payments(limit: nil)
    query = {}
    query[:limit] = limit if limit
    parse get(payments_uri, query)
  end

  # Get the payment information for the given payment ID.
  def self.payment(payment_id)
    parse get(payment_uri(payment_id))
  end

end
