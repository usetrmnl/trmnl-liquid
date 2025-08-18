# TRMNL::Liquid

A set of Liquid filters and tags used to render custom plugins for [TRMNL](https://usetrmnl.com).

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

## Usage

```ruby
require 'trmnl-liquid'

# register filters and tags with Liquid::Template
TRMNL::Liquid.register_all

markup = "Hello {{ count | number_with_delimiter }} people!"
template = TRMNL::Liquid::Template.parse(markup)
rendered = template.render(count: 1337)
# => "Hello 1,337 people!"
```

## Internationalization (Optional Peer Dependencies)

Some filter functions (e.g. `number_to_currency`, `l_word`, and `l_date`) require translations provided by the [rails-i18n](https://rubygems.org/gems/rails-i18n) and [trmnl-i18n](https://rubygems.org/gems/trmnl-i18n) gems.

These dependencies are optional, and if missing will fall back to default behavior.

```ruby
# optional peer dependencies
gem "rails-i18n", "~> 8.0"
gem "trmnl-i18n", github: "usetrmnl/trmnl-i18n", branch: "main" # recommended for the latest changes
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/usetrmnl/trmnl-liquid.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
