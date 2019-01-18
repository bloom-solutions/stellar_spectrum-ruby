module StellarSpectrum
  class Log
    
    TAG = "[StellarSpectrum]".freeze
    LEVELS = [:debug, :warn, :info, :error, :fatal].freeze

    class << self
      LOG_LEVELS.each do |level|

        define_method level do |message|
          logger = StellarSpectrum.configuration.logger
          if logger
            logger.send(level, "#{LOG_TAG}: #{message}")
          end
        end

      end
    end

  end
end
