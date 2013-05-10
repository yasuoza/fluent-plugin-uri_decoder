# Fluent::Plugin::UriDecoder

Fluent plugin to decode uri encoded value.

## Installation

Add this line to your application's Gemfile:

    gem 'fluent-plugin-uri_decoder'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-uri_decoder

## Usage

```xml
<match input.**>
  type uri_decode
  key_name query_param
  remove_prefix input
  add_prefix decoded
</match>
```

This re-emits `decoded.**` tagged message with uri decoded.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
