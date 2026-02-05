# TRMNL Liquid

A set of Liquid filters and tags used to render custom plugins for [TRMNL](https://trmnl.com).

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add trmnl-liquid
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install trmnl-liquid
```

## Setup

For [Rails](https://rubyonrails.org) folks, you'll need to load the Rails feature but you *only need to do this once* (typically via an initializer). Example:

``` ruby
TRMNL::Liquid.load :rails
```

The above will load the Rails i18n support and other functionality for you to use this gem within a Rails application. For any application that isn't using Rails, we have fallbacks that should be sufficient but we're working to close that gap further. For instance, here's how you can configure this gem within a [Hanami](https://hanamirb.org) application as a *provider*:


``` ruby
Hanami.app.register_provider :liquid, namespace: true do
  prepare { require "trmnl/liquid" }

  start do
    default = TRMNL::Liquid.new { |environment| environment.error_mode = :strict }

    renderer = lambda do |template, data, environment: default|
      Liquid::Template.parse(template, environment:).render data
    end

    register :default, renderer
  end
end
```

If you ignore the provider logic and only focus on the body of the provider `start` life cyle, this can provide inspiration on how you can configure this gem further and use within your own application regardless of web stack.

## Usage

Functionality is achieved by parsing a template with the option `{ environment: TRMNL::Liquid.new }`. The environment concept was introduced in [v5.6.0](https://github.com/Shopify/liquid/releases/tag/v5.6.0) of the  `liquid` gem as a safer alternative to global registration of tags, filters, and so on. See [lib/trmnl/liquid/filters.rb](lib/trmnl/liquid/filters.rb) for the currently-supported filters.

```ruby
require "trmnl/liquid"

markup = "Hello {{ count | number_with_delimiter }} people!"
environment = TRMNL::Liquid.new # same arguments as Liquid::Environment.build
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

For more information, check out our help guides:

- [Liquid 101](https://help.trmnl.com/en/articles/10671186-liquid-101)
- [Advanced Liquid](https://help.trmnl.com/en/articles/10693981-advanced-liquid)
- [Custom Plugin Filters](https://help.trmnl.com/en/articles/10347358-custom-plugin-filters)

### Rails (optional)

The following is optional and only works for Rails applications. Once again, you'll want to enable Rails support by adding the following as an initializer:

``` ruby
TRMNL::Liquid.load :rails
```

Then you can include internationalization and/or number and text formatting as described below.

#### Internationalization

Some filter functions (e.g. `number_to_currency`, `l_word`, and `l_date`) require translations provided by the [rails-i18n](https://rubygems.org/gems/rails-i18n) and [trmnl-i18n](https://rubygems.org/gems/trmnl-i18n) gems. These dependencies are optional, and if missing will fall back to default behavior. If you want to internationalize, also include these gems:

```ruby
# optional peer dependencies
gem "rails-i18n", "~> 8.0"
gem "trmnl-i18n", github: "usetrmnl/trmnl-i18n", branch: "main" # recommended for the latest changes
```

#### Number and Text Formatting

This gem does not _require_ ActionView, but it will leverage ActionView helpers if they are available.

```ruby
# optional peer dependency
gem "actionview", "~> 8.0"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To publish, run the following:

``` ruby
# Step 0: You only need to do this once.
bundle install gemsmith

# Step 1: Edit the version number in trmnl-liquid.gemspec and update it to your desired version.

# Step 2: Publish the new version.
gemsmith --publish
```

## Contributing

Enhancements, bugs, code reviews, and other requests are welcome via [GitHub](https://github.com/usetrmnl/trmnl-liquid).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
