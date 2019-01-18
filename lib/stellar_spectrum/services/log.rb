module StellarSpectrum
  class Log
    
    LOG_TAG = "[StellarSpectrum]"

    def self.write(message)
      logger = StellarSpectrum.configuration.logger

      if logger
        logger.warn("#{LOG_TAG}: #{message}")
      end
    end

  end
end
