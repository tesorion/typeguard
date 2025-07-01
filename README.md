# Typeguard

Runtime type checking for Ruby type signatures. Currently supports YARD and a subset of RBS.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add typeguard

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install typeguard

## Usage
Call `configure` and `process!` at the end of the original code to add type checking to it.

```ruby
require 'typeguard'

Typeguard.configure do |config|
  config.enabled = true                                  # does nothing if false
  config.source = :yard                                  # :yard or :rbs
  config.target = ['bin/example.rb']                     # signatures file/dir
  config.reparse = true                                  # reparse YARD sigs
  config.at_exit_report = true                           # print findings
  config.resolution.raise_on_name_error = false          # undefined constants
  config.wrapping.raise_on_unexpected_arity = false      # amount of parameters
  config.wrapping.raise_on_unexpected_visibility = false # scope (public/private/..)
  config.validation.raise_on_unexpected_argument = false # type check args
  config.validation.raise_on_unexpected_return = false   # type check return
end.process!
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/typeguard.
