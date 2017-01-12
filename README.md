# Cardinity

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cardinity'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cardinity

## Usage

### Configuration

    Cardinity.configure!(options)
    
Where options should contain:
 - key
 - secret
 - api_base (optional, if you want to point the requests somewhere else than Cardinity servers)

### Creating Payments

    Cardinity.create_payment(payment_data)

Where `payment_data` is a plain `Hash`. See rdoc or [Cardinity API doc](https://developers.cardinity.com/api/v1/) to see
what attributes are allowed and required.

    Cardinity.finalize_payment(payment_id, authorization_data)

Where `payment_id` is an id of previously created payment and `authorization_data` is
a `Hash` with single key `authorize_data`.

### Other stuff

    Cardinity.payments

Returns the last 10 payments made.


## Development

After checking out the repo, run `bin/setup` to install dependencies. 
Then, run `rake test` to run the tests. You can also run `bin/console` 
for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 
To release a new version, update the version number in `version.rb`, and 
then run `bundle exec rake release`, which will create a git tag for 
the version, push git commits and tags, and 
push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at 
https://github.com/honzasterba/cardinity. This project is intended to be a 
safe, welcoming space for collaboration, and contributors are 
expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) 
code of conduct.


## License

The gem is available as open source under the terms of 
the [MIT License](http://opensource.org/licenses/MIT).

