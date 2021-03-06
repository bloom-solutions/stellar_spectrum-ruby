# StellarSpectrum

[![Build Status](https://travis-ci.com/bloom-solutions/stellar_spectrum-ruby.svg?branch=master)](https://travis-ci.com/bloom-solutions/stellar_spectrum-ruby)

Use Stellar payment channels in Ruby with ease.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stellar_spectrum'
```

## Usage

In an initializer:

```ruby
StellarSpectrum.configure do |c|
  c.redis_url = "redis://redis"

  # Add as many seeds as you want. They must be funded, and are the source of transaction fees. The product of the time in seconds it takes to make a new ledger in Stellar and the number of transactions you want to be able to do per second is the number of Stellar seeds you should place here. For example:

  # 10 second ledger time * 5 transactions per second = 50 channels
  c.seeds = [
    "STELLAR-PAYMENT-CHANNEL-SOURCE-1",
    "STELLAR-PAYMENT-CHANNEL-SOURCE-2",
    "STELLAR-PAYMENT-CHANNEL-SOURCE-3",
    "STELLAR-PAYMENT-CHANNEL-SOURCE-4",
  ]
end
```

### Initializing a Client

This is the instance that you will be interacting with to craft transactions.

```ruby
spectrum = StellarSpectrum.new(
  redis_url: "...", # only to override the default set in the config
  seeds: %w(SEED1 SEED2), # only to override the default set in the config
)
```

### Sending a Payment

The method below picks an available channel in the config's seeds.

```ruby
spectrum.send_payment(
  from: Stellar::Account.from_seed("seed of account that will send 30 XLM"),
  to: Stellar::Account.from_address("destination address"),
  amount: Stellar::Amount.new(30),
)
```

At this point, one of the payment channels will be marked as "locked", and will not be used until the next Stellar ledger is created.

When another transaction is created, an available (unlocked) payment channel will be chosen.

If all payment channels are unavailable (locked), then the call will block the Ruby process/thread until a channel is available. Therefore, unless you have way more channels than you will ever consume, we strongly recommend you send transactions in a background worker like Sidekiq.

#### Retries

When the call to Horizon [times out](https://www.stellar.org/developers/horizon/reference/errors/timeout.html), we do not know whether or not the asset was sent.

Because there are many payment channels to choose from, and each channel has their own sequence number, it would be complicated to control it from outside the gem. Therefore, this gem will retry for you. When a timeout is encountered the same channel and the same sequence number will be used to retry, as suggested in the Stellar docs.

If the response is successful, the gem will mark the request as successful, and return the response.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bloom-solutions/stellar_spectrum-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the StellarSpectrum project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/bloom-solutions/stellar_spectrum-ruby/blob/master/CODE_OF_CONDUCT.md).
