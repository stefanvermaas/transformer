# frozen_string_literal: true

require "test_helper"

module Transformer
  class SchemaAttributeTest < MiniTest::Test
    def test_converts_name_to_symbol
      assert_equal :email, SchemaAttribute.new(:email).name
      assert_equal :email, SchemaAttribute.new("email").name
    end

    def test_correctly_compares_attributes
      name_attribute = SchemaAttribute.new(:first_name)

      refute_equal name_attribute, SchemaAttribute.new(:email)
      assert_equal name_attribute, SchemaAttribute.new(:first_name)
      assert_equal name_attribute, name_attribute
    end

    def test_raises_on_unsupported_cast_type
      assert_raises SchemaAttribute::UnsupportedCastType do
        SchemaAttribute.new(:email, cast_type: :unknown_cast_type)
      end
    end

    def test_normalizes_cast_type_to_symbol
      schema_attribute = SchemaAttribute.new(:email, cast_type: "array")
      assert_equal :array, schema_attribute.cast_type
    end

    def test_defaults_to_string_cast_type
      schema_attribute = SchemaAttribute.new(:email)
      assert_equal :string, schema_attribute.cast_type
    end
  end
end
