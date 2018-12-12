module StellarSpectrum
  class GetChannelAccounts

    extend LightService::Action
    expects :seeds
    promises :channel_accounts

    executed do |c|
      puts "Making accounts from #{c.seeds.inspect}"
      c.channel_accounts = c.seeds.map do |seed|
        Stellar::Account.from_seed(seed)
      end
    end

  end
end
