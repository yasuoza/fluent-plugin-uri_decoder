require "test_helper"
require "fluent/plugin/filter_uri_decode"

class Fluent::URIDecoderFilterTest < Test::Unit::TestCase
  CONFIG0 = %[
    key_name encoded
  ]

  CONFIG1 = %[
    key_name encoded
    key_names encoded, another_encoded
  ]

  def create_driver(conf)
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::URIDecoderFilter).configure(conf)
  end

  sub_test_case "configure" do
    test "simple" do
      d = create_driver(CONFIG0)
      assert_equal "encoded", d.instance.key_name
      assert_equal ["encoded"], d.instance.key_names
    end

    test "multiple key_names" do
      d = create_driver(CONFIG1)
      assert_equal "encoded", d.instance.key_name
      assert_equal ["encoded", "another_encoded"], d.instance.key_names
    end
  end

  sub_test_case "decode message" do
    test "single" do
      d = create_driver(CONFIG0)
      d.run(default_tag: "test") do
        d.feed({"encoded" => "%23hash", "another_encoded" => "%23another_hash"})
      end
      expected_records = [
        {
          "encoded" => "#hash",
          "another_encoded" => "%23another_hash"
        }
      ]
      assert_equal(expected_records, d.filtered_records)
    end

    test "multiple" do
      d = create_driver(CONFIG1)
      d.run(default_tag: "test") do
        d.feed({"encoded" => "%23hash", "another_encoded" => "%23another_hash"})
      end
      expected_records = [
        {
          "encoded" => "#hash",
          "another_encoded" => "#another_hash"
        }
      ]
      assert_equal(expected_records, d.filtered_records)
    end
  end
end
