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
      assert_includes model.schema_definition, SchemaAttribute.new(:email)
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

    def test_schema_to_hash
      model = Class.new Transformer::Model do
        schema do
          attribute :name
        end
      end

      original_data = { name: "Travel Bag" }

      assert_equal "Travel Bag", model.new(original_data).to_h[:name]
      assert_equal "Travel Bag", model.to_h(original_data)[:name]
    end

    def test_schema_to_json
      model = Class.new Transformer::Model do
        schema do
          attribute :name
        end
      end

      original_data = { name: "Travel Bag" }

      assert_equal original_data.to_json, model.new(original_data).to_json
      assert_equal original_data.to_json, model.to_json(original_data)
    end
  end
end
