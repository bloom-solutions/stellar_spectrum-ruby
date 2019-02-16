module StellarSpectrum
  module SendingPayment
    class GetSleepForRetry

      MAX = Client::MAX_LOCK_TIME_IN_SECONDS
      LEEWAY = 5.freeze

      def self.call(n)
        fibo = Fibo.(n)
        return fibo if fibo < MAX
        MAX - LEEWAY
      end

    end
  end
end
