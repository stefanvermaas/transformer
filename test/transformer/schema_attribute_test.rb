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
  end
end
