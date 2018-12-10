require "gem_config"
require "light-service"
require "stellar_spectrum/version"
require "stellar_spectrum/client"
require "stellar-sdk"
require "redis"
require "active_support/core_ext/hash/except"
require "active_support/core_ext/object/blank"
require 'active_support/core_ext/integer/inflections'
require "stellar_spectrum/services/get_available_channels"
require "stellar_spectrum/services/get_key_for_address"
require "stellar_spectrum/services/get_locked_accounts"
require "stellar_spectrum/services/init_redis"

module StellarSpectrum

  include GemConfig::Base

  with_configuration do
    has :redis_url, classes: [NilClass, String]
    has :seeds, classes: [NilClass, Array]
    has :horizon_url, classes: [NilClass, String]
    has :logger
  end

  def self.new(*args)
    Client.new(*args)
  end

end
