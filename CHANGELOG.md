# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.4] - 2018-12-13
### Fixed
- Remove accidentally added puts :/

## [1.1.3] - 2018-12-13
### Fixed
- Check if the sequence number in horizon has bumped up before unlocking

## [1.1.2] - 2018-12-13
### Fixed
- Do not blow up if `Faraday::ClientError#response` is nil

## [1.1.1] - 2018-12-13
### Fixed
- [Make unlocking strategy safer](https://github.com/bloom-solutions/stellar_spectrum-ruby/pull/9)

## [1.1.0] - 2018-12-12
### Added
- Retry when timeout is encountered [#6](https://github.com/bloom-solutions/stellar_spectrum-ruby/pull/6)

## [1.0.0] - 2018-11-30
### Changed
- Use stellar-sdk => 0.6.0

## [0.2.0]
### Fixed
- Do not require `redis_url`, `seeds`, `horizon_url` to be set in the gem's global config

### Changed
- Use the `to` keyword instead of `destination`

## [0.1.0] - 2018-10-19
### Added
- Initial release
