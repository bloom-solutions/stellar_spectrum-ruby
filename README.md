# StellarSpectrum

Use Stellar payment channels in Ruby with ease.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stellar_spectrum'
```

When used in a multi-process environment (i.e. web workers, background workers) ensure Redis is available.

## Usage

In an initializer:

```ruby
StellarSpectrum.configure do |c|
  # When redis_url is not set, the memory store will be used to keep track of what payment channels are available

  # If you're running on a multi-process environment, like a web server and background workers, you should configure StellarSpectrum to use Redis to keep track of the locked payment channels.
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
  from: "SEED OF SOURCE OF BTC",
  to: "ADDRESS OF DESTINATION",
  amount: [1, :alphanum4, "BTC", "ISSUER"],
)
```

At this point, one of the payment channels will be marked as "locked", and will not be used until the next Stellar ledger is created.

When another transaction is created, an available (unlocked) payment channel will be chosen.

If all payment channels are unavailable (locked), then the call will block the Ruby process/thread until a channel is available. Therefore, unless you have way more channels than you will ever consume, we strongly recommend you send transactions in a background worker like Sidekiq.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/stellar_spectrum. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the StellarSpectrum project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/stellar_spectrum/blob/master/CODE_OF_CONDUCT.md).
