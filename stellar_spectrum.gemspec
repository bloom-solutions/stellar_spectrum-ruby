
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "stellar_spectrum/version"

Gem::Specification.new do |spec|
  spec.name          = "stellar_spectrum"
  spec.version       = StellarSpectrum::VERSION
  spec.authors       = ["Ramon Tayag", "Jasper Martin"]
  spec.email         = ["ramon.tayag@gmail.com", "jasper@bloom.solutions"]

  spec.summary       = %q{Use Stellar payment channels in Ruby with ease}
  spec.homepage      = "https://github.com/bloom-solutions/stellar_spectrum-ruby"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/bloom-solutions/stellar_spectrum-ruby"
    spec.metadata["changelog_uri"] = "https://github.com/bloom-solutions/stellar_spectrum-ruby/blob/master/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "gem_config"
  spec.add_dependency "redis"
  spec.add_dependency "stellar-sdk", ">= 0.6.0"
  spec.add_dependency "light-service"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
end
