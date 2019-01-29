module StellarSpectrum
  class Fibo

    def self.call(n)
      return n if n <= 1

      @cache ||= {}
      cached_value = @cache[n]
      return cached_value unless cached_value.nil?

      @cache[n] = self.(n-1) + self.(n-2)
    end

  end
end
