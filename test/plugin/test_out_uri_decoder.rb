require 'test_helper'
require 'fluent/plugin/out_uri_decode'

class Fluent::URIDecoderOutputTest < Test::Unit::TestCase
  CONFIG0 = %[
    type uri_decode
    key_name encoded
    tag decoded
  ]

  CONFIG1 = %[
    type uri_decode
    key_name encoded
    remove_prefix encoded
    add_prefix decoded
  ]

  CONFIG2 = %[
    type uri_decode
    key_names encoded, another_encoded
    remove_prefix encoded
    add_prefix decoded
  ]

  def setup
    Fluent::Test.setup
  end

  def create_driver(conf=CONFIG0)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::URIDecoderOutput).configure(conf)
  end

  def test_configure
    d = create_driver(CONFIG0)
    assert_equal 'encoded', d.instance.key_name
    assert_equal 'decoded', d.instance.tag

    d = create_driver(CONFIG1)
    assert_equal 'encoded', d.instance.remove_prefix
    assert_equal 'decoded', d.instance.add_prefix

    d = create_driver(CONFIG2)
    assert_equal ['encoded', 'another_encoded'], d.instance.key_names
  end

  def test_tag_mangle
    p = create_driver(CONFIG0).instance
    assert_equal 'decoded', p.tag_mangle('data')
    assert_equal 'decoded', p.tag_mangle('test.data')

    p = create_driver(CONFIG1).instance
    assert_equal 'decoded.data', p.tag_mangle('data')
    assert_equal 'decoded.test.data', p.tag_mangle('test.data')
  end

  def test_emit_with_tag_specification
    d = create_driver(CONFIG0)
    time = event_time
    d.run(default_tag: 'test') do
      d.feed(time, {'encoded' => '%23hash', 'value' => 1})
    end

    events = d.events
    assert_equal 1, events.size
    assert_equal 'decoded', events[0][0]
    assert_equal time,  events[0][1]
    assert_equal '#hash', events[0][2]['encoded']
  end

  def test_emit_with_prefix_specification
    d = create_driver(CONFIG1)
    time = event_time
    d.run(default_tag: 'encoded.message') do
      d.feed(time, {'encoded' => '%23hash', 'value' => 1})
    end

    events = d.events
    assert_equal 1, events.size
    assert_equal 'decoded.message', events[0][0]
    assert_equal time,  events[0][1]
    assert_equal '#hash', events[0][2]['encoded']
  end

  def test_emit_with_multi_key_names
    d = create_driver(CONFIG2)
    time = event_time
    d.run(default_tag: 'encoded.message') do
      d.feed(time, {'encoded' => '%23hash', 'another_encoded' => '%23another_hash'})
    end

    events = d.events
    assert_equal 1, events.size
    assert_equal 'decoded.message', events[0][0]
    assert_equal time,  events[0][1]
    assert_equal '#hash', events[0][2]['encoded']
    assert_equal '#another_hash', events[0][2]['another_encoded']
  end

  def test_multiple_emit
    d = create_driver(CONFIG2)
    time = event_time
    d.run(default_tag: 'encoded.message') do
      d.feed(time, {'encoded' => '%23hash', 'another_encoded' => '%23another_hash'})
    end

    events = d.events
    events << d.events.flatten
    assert_equal 2, events.size
    assert_equal 'decoded.message', events[0][0]
    assert_equal time,  events[0][1]
    assert_equal '#hash', events[0][2]['encoded']
    assert_equal '#another_hash', events[0][2]['another_encoded']

    assert_equal 'decoded.message', events[1][0]
    assert_equal time,  events[1][1]
    assert_equal '#hash', events[1][2]['encoded']
    assert_equal '#another_hash', events[1][2]['another_encoded']
  end
end
