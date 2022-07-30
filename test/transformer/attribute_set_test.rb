# frozen_string_literal: true

require "test_helper"

module Transformer
  class AttributeSetTest < MiniTest::Test
    def setup
      @model = Class.new Transformer::Model do
        schema do
          attribute :first_name
          attribute :last_name
          attribute :email
        end
      end

      @user_hash = { first_name: "Jane", last_name: "Doe", email: "jane@example.com" }
    end

    def test_read_and_cast_attributes
      user_mapping = @model.new(@user_hash).to_h

      assert_equal "Jane", user_mapping[:first_name]
      assert_equal "Doe", user_mapping[:last_name]
    end

    def test_turns_attribute_set_to_json
      user_mapping = @model.new(@user_hash).to_json

      assert_equal String, user_mapping.class
      assert_equal @user_hash.to_json, user_mapping
    end

    def test_casting_selected_attributes_only
      user_mapping = @model.new(@user_hash).to_h(only: :first_name)

      assert_nil user_mapping[:last_name]
      assert_nil user_mapping[:email]
      assert_equal "Jane", user_mapping[:first_name]
    end

    def test_excepted_attributes
      user_mapping = @model.new(@user_hash).to_h(except: %i[first_name email])

      assert_nil user_mapping[:first_name]
      assert_nil user_mapping[:email]
      assert_equal "Doe", user_mapping[:last_name]
    end
  end
end
