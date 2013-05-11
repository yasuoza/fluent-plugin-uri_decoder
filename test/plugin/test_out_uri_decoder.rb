require 'test_helper'
require 'fluent/plugin/out_uri_decode'

class Fluent::URIDecorderTest < MiniTest::Unit::TestCase
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


  def create_driver(conf=CONFIG0, tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::URIDecoder, tag).configure(conf)
  end

  def test_configure
    d = create_driver(CONFIG0)
    assert_equal 'encoded', d.instance.key_name
    assert_equal 'decoded', d.instance.tag

    d = create_driver(CONFIG1)
    assert_equal 'encoded', d.instance.remove_prefix
    assert_equal 'decoded', d.instance.add_prefix

    d = create_driver(CONFIG2)
    assert_equal 'encoded, another_encoded', d.instance.key_names
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
    time = Time.now.to_i
    d.run do
      d.emit({'encoded' => '%23hash', 'value' => 1}, time)
    end

    emits = d.emits
    assert_equal 1, emits.size
    assert_equal 'decoded', emits[0][0]
    assert_equal time,  emits[0][1]
    assert_equal '#hash', emits[0][2]['encoded']
  end

  def test_emit_with_prefix_specification
    d = create_driver(CONFIG1, 'encoded.message')
    time = Time.now.to_i
    d.run do
      d.emit({'encoded' => '%23hash', 'value' => 1}, time)
    end

    emits = d.emits
    assert_equal 1, emits.size
    assert_equal 'decoded.message', emits[0][0]
    assert_equal time,  emits[0][1]
    assert_equal '#hash', emits[0][2]['encoded']
  end

  def test_emit_with_multi_key_names
    d = create_driver(CONFIG2, 'encoded.message')
    time = Time.now.to_i
    d.run do
      d.emit({'encoded' => '%23hash', 'another_encoded' => '%23another_hash'}, time)
    end

    emits = d.emits
    assert_equal 1, emits.size
    assert_equal 'decoded.message', emits[0][0]
    assert_equal time,  emits[0][1]
    assert_equal '#hash', emits[0][2]['encoded']
    assert_equal '#another_hash', emits[0][2]['another_encoded']
  end

  def test_multiple_emit
    d = create_driver(CONFIG2, 'encoded.message')
    time = Time.now.to_i
    d.run do
      d.emit({'encoded' => '%23hash', 'another_encoded' => '%23another_hash'}, time)
    end

    emits = d.emits
    emits << d.emits.flatten
    assert_equal 2, emits.size
    assert_equal 'decoded.message', emits[0][0]
    assert_equal time,  emits[0][1]
    assert_equal '#hash', emits[0][2]['encoded']
    assert_equal '#another_hash', emits[0][2]['another_encoded']

    assert_equal 'decoded.message', emits[1][0]
    assert_equal time,  emits[1][1]
    assert_equal '#hash', emits[1][2]['encoded']
    assert_equal '#another_hash', emits[1][2]['another_encoded']
  end
end
