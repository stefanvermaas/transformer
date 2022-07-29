# frozen_string_literal: true

require "test_helper"

module Transformer
  class ModelTest < MiniTest::Test
    def test_defining_schema_definition
      model = Class.new Transformer::Model do
        schema do
          attribute :email
        end
      end

      refute_nil model.schema_definition
      assert_includes model.schema_definition.attributes, SchemaAttribute.new(:email)
    end

    def test_data_assignment
      model = Class.new Transformer::Model do
        schema do
          attribute :email
        end
      end

      user_hash = { email: "jane@example.com" }
      assert_equal user_hash, model.new(user_hash).data
    end
  end
end
