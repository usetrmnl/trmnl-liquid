# TRMNL-Flavored Liquid Templates

A set of Liquid filters and tags used to render custom plugins for [TRMNL](https://usetrmnl.com).

## Usage

Functionality is achieved by parsing a template with the option `{ environment: TRMNL::Liquid.build_environment }`.

The environment concept was introduced in [v5.6.0](https://github.com/Shopify/liquid/releases/tag/v5.6.0) of the  `liquid` gem as a safer alternative to global registration of tags, filters, and so on.

See [lib/trmnl/liquid/filters.rb](lib/trmnl/liquid/filters.rb) for the currently-supported filters.

```ruby
require 'trmnl/liquid'

markup = "Hello {{ count | number_with_delimiter }} people!"
environment = TRMNL::Liquid.build_environment # same arguments as Liquid::Environment.build
template = Liquid::Template.parse(markup, environment: environment)
rendered = template.render(count: 1337)
# => "Hello 1,337 people!"
```


Additionally, the `{% template %}` tag defines reusable chunks of markup:

```liquid
{% template say_hello %}
<h1>Why hello there, {{ name }}!</h1>
{% endtemplate %}

{% render "say_hello", name: "General Kenobi" %}
```

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add trmnl-liquid
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install trmnl-liquid
```

### Internationalization (Optional)

Some filter functions (e.g. `number_to_currency`, `l_word`, and `l_date`) require translations provided by the [rails-i18n](https://rubygems.org/gems/rails-i18n) and [trmnl-i18n](https://rubygems.org/gems/trmnl-i18n) gems.

These dependencies are optional, and if missing will fall back to default behavior. If you want to internationalize, also include these gems:

```ruby
# optional peer dependencies
gem "rails-i18n", "~> 8.0"
gem "trmnl-i18n", github: "usetrmnl/trmnl-i18n", branch: "main" # recommended for the latest changes
```

### Number and Text Formatting (Optional)

This gem does not _require_ ActionView, but it will leverage ActionView helpers if they are available.

```ruby
# optional peer dependency
gem "actionview", "~> 8.0"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/usetrmnl/trmnl-liquid.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
