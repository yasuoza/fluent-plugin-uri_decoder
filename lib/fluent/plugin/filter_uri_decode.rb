require "fluent/plugin/filter"
require "uri"

module Fluent::Plugin
  class URIDecoderFilter < Fluent::Plugin::Filter
    Fluent::Plugin.register_filter("uri_decode", self)

    config_param :key_name, :string, default: nil
    config_param :key_names, :array, default: []

    def configure(conf)
      super
      @key_names << @key_name if @key_name
      @key_names.uniq!
    end

    def filter(tag, time, record)
      @key_names.each do |key_name|
        next unless record.key?(key_name)
        record[key_name] = URI.decode_www_form_component(record[key_name])
      end
      record
    end
  end
end
