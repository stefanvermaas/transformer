# frozen_string_literal: true

require "test_helper"

module Transformer
  class AttributeSetTest < MiniTest::Test
    def setup
      @data = { first_name: "Jane", last_name: "Doe", email: "jane@example.com" }
      context = Struct.new(:data).new(@data)

      schema_definition = SchemaDefinition.new
      schema_definition.attributes :first_name, :last_name, :email

      @attribute_set = AttributeSet.new(context, schema_definition)
    end

    def test_read_and_cast_attributes
      output = @attribute_set.to_h

      assert_equal "Jane", output[:first_name]
      assert_equal "Doe", output[:last_name]
    end

    def test_turns_attribute_set_to_json
      output = @attribute_set.to_json

      assert_equal String, output.class
      assert_equal @data.to_json, output
    end

    def test_casting_selected_attributes_only
      output = @attribute_set.to_h(only: :first_name)

      assert_nil output[:last_name]
      assert_nil output[:email]
      assert_equal "Jane", output[:first_name]
    end

    def test_excepted_attributes
      output = @attribute_set.to_h(except: %i[first_name email])

      assert_nil output[:first_name]
      assert_nil output[:email]
      assert_equal "Doe", output[:last_name]
    end

    def test_casting_selected_attributes_only_for_to_json
      json_output = @attribute_set.to_json(only: :first_name)

      assert_match(/jane/i, json_output)
      refute_match(/doe/i, json_output)
      refute_match(/jane@example.com/i, json_output)
    end

    def test_excepted_attributes_for_to_json
      json_output = @attribute_set.to_json(except: :first_name)

      refute_match(/jane$/i, json_output)
      assert_match(/doe/i, json_output)
      assert_match(/jane@example.com/i, json_output)
    end
  end
end
