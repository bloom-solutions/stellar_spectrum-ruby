module StellarSpectrum
  class Log
    
    TAG = "[StellarSpectrum]".freeze
    LEVELS = [:debug, :warn, :info, :error, :fatal].freeze

    class << self
      LEVELS.each do |level|

        define_method level do |message|
          logger = StellarSpectrum.configuration.logger
          if logger
            logger.send(level, "#{TAG}: #{message}")
          end
        end

      end
    end

  end
end
