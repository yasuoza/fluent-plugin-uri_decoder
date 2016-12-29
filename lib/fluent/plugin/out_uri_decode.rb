class Fluent::URIDecoder < Fluent::Output
  Fluent::Plugin.register_output('uri_decode', self)

  config_param :tag, :string, :default => nil
  config_param :remove_prefix, :string, :default => nil
  config_param :add_prefix, :string, :default => nil
  config_param :key_name, :string, :default => nil
  config_param :key_names, :string, :default => ''

  def initialize
    super
    require 'uri'
  end

  def configure(conf)
    super

    if !@remove_prefix && !@add_prefix && !@tag
      raise Fluent::ConfigError, "missing both of remove_prefix and add_prefix"
    end
    if @tag && @remove_prefix && @add_prefix
      raise Fluent::ConfigError, "either remove_prefix/add_prefix must not be specified"
    end
    if @remove_prefix
      @removed_prefix_string = @remove_prefix + '.'
      @removed_length = @removed_prefix_string.length
    end
    if @add_prefix
      @added_prefix_string = @add_prefix + '.'
    end
  end

  def tag_mangle(tag)
    if @tag
      @tag
    else
      if @remove_prefix and
         (tag == @remove_prefix || tag.start_with?(@removed_prefix_string) && tag.length > @removed_length)
        tag = tag[@removed_length..-1]
      end
      if @add_prefix
        tag =
          if tag and tag.length > 0
            @added_prefix_string + tag
          else
            @add_prefix
          end
      end
      tag
    end
  end

  def emit(tag, es, chain)
    tag = tag_mangle(tag)

    @_key_names ||= @key_names.split(/,\s*/)
    @_key_names << @key_name if @key_name
    @_key_names.uniq!

    es.each do |time, record|
      @_key_names.each do |key_name|
        record[key_name] = URI.decode_www_form_component(record[key_name] || '')
      end

      router.emit(tag, time, record)
    end

    chain.next
  end
end
