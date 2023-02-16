[![Build Status](https://github.com/get-bridge/scorm_engine/workflows/ScormEngine/badge.svg)](https://github.com/get-bridge/scorm_engine/actions)
[![Gem Version](https://badge.fury.io/rb/scorm_engine.svg)](https://badge.fury.io/rb/scorm_engine)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](https://get-bridge.github.io/scorm_engine/)

# ScormEngine

A ruby client for Rustici's SCORM Engine 2017.1 API and limited support for the Engine 20.1 API v2.

- https://rustici-docs.s3.amazonaws.com/engine/2017.1.x/index.html
- https://rustici-docs.s3.amazonaws.com/engine/20.1.x/api/apiV2.html
- https://support.scorm.com/hc/en-us/sections/115000043974-Release-Notes
- https://rustici-docs.s3.amazonaws.com/engine/2017.1.x/api.html
- https://rustici-docs.s3.amazonaws.com/engine/2017.1.x.dispatch/api-dispatch.html
- https://rustici-docs.s3.amazonaws.com/engine/2017.1.x/Configuration/GeneratedConfigurationSettings.html

## Installation

Add this line to your application's Gemfile:

    gem 'scorm_engine'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scorm_engine

## Usage #TODO

## Testing

All in one testing for rubocop, rspec, and yard doc generation with the default rake task:

    bin/rake

To test running these specs against an actual SCORM server, create a `.env.test.local`
- `cp .env.test .env.test.local`
- Update the values in `.env.test.local` with the values you want overridden.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/get-bridge/scorm_engine.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
