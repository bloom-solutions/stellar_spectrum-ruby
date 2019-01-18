module StellarSpectrum
  class Log

    def self.write(message)
      logger = StellarSpectrum.configuration.logger

      if logger
        logger.warn(message)
      end
    end

  end
end
