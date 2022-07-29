# frozen_string_literal: true

require "test_helper"

module Transformer
  class SchemaDefinitionTest < MiniTest::Test
    def test_starts_empty
      schema_definition = SchemaDefinition.new
      assert_equal [], schema_definition.attributes
    end

    def test_adding_attributes
      schema_definition = SchemaDefinition.new
      refute_includes schema_definition.attributes, SchemaAttribute.new(:email)

      schema_definition.attribute(:email)
      assert_includes schema_definition.attributes, SchemaAttribute.new(:email)
    end

    def test_preventing_duplicate_attributes
      schema_definition = SchemaDefinition.new

      schema_definition.attribute(:email)
      schema_definition.attribute(:email)

      assert_equal 1, schema_definition.attributes.length
    end

    def test_adding_multiple_attributes_at_once
      schema_definition = SchemaDefinition.new
      schema_definition.attributes(:first_name, :last_name)

      assert_equal 2, schema_definition.attributes.length
      assert_includes schema_definition.attributes, SchemaAttribute.new(:first_name)
      assert_includes schema_definition.attributes, SchemaAttribute.new(:last_name)
    end
  end
end
