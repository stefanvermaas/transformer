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

    def test_normalizes_cast_type_to_symbol
      schema_attribute = SchemaAttribute.new(:email, cast_type: "array")
      assert_equal :array, schema_attribute.cast_type
    end

    def test_defaults_to_nil_cast_type
      schema_attribute = SchemaAttribute.new(:email)
      assert_nil schema_attribute.cast_type
    end

    def test_defaults_to_name_as_value_before_read
      schema_attribute = SchemaAttribute.new(:email)
      assert_equal schema_attribute.name, schema_attribute.value_before_read
    end

    class SchemaAttributeValueTest < MiniTest::Test
      def setup
        @context = Class.new do
          def data
            {
              id: 123,
              email: "jane@example.com",
              first_name: "Jane",
              last_name: "Joules",
              metadata: {
                username: "jane89",
                user_profile_id: "456",
                hour_rate: "100.00"
              }
            }
          end

          def full_name
            "#{data[:first_name]} #{data[:last_name]}"
          end
        end
      end

      def test_value_without_context_returns_nil
        schema_attribute = SchemaAttribute.new(:email)
        assert_nil schema_attribute.value
      end

      def test_value_is_extractable_as_string_from_symbol_hash_key
        schema_attribute = SchemaAttribute.new(:email, value_before_read: "email")
        assert_equal("jane@example.com", schema_attribute.value { @context.new })
      end

      def test_value_is_extractable_as_string_from_string_hash_key
        context = Class.new do
          def data
            { "email" => "jane@example.com" }
          end
        end

        schema_attribute = SchemaAttribute.new(:email, value_before_read: "email")
        assert_equal("jane@example.com", schema_attribute.value { context.new })
      end

      def test_value_is_extractable_as_string_from_nested_hash
        schema_attribute = SchemaAttribute.new(:username, value_before_read: "metadata.username")
        assert_equal("jane89", schema_attribute.value { @context.new })
      end

      def test_value_is_extractable_as_symbol_method_reference
        schema_attribute = SchemaAttribute.new(:full_name, value_before_read: :full_name)
        assert_equal("Jane Joules", schema_attribute.value { @context.new })
      end

      def test_value_is_extractable_as_symbol_for_root_hash
        schema_attribute = SchemaAttribute.new(:first_name, value_before_read: :first_name)
        assert_equal("Jane", schema_attribute.value { @context.new })
      end

      def test_value_is_extractable_as_proc_with_static_value
        schema_attribute = SchemaAttribute.new(:static, value_before_read: -> { "static" })
        assert_equal("static", schema_attribute.value { @context.new })
      end

      def test_value_is_extractable_as_proc_with_dynamic_value
        schema_attribute = SchemaAttribute.new(:first_name,
                                               value_before_read: -> { data[:first_name] })

        assert_equal("Jane", schema_attribute.value { @context.new })
      end

      def test_value_is_not_casted_without_cast_type
        schema_attribute = SchemaAttribute.new(:first_name)
        assert_equal(String, schema_attribute.value { @context.new }.class)
      end

      def test_value_is_castable_to_string
        schema_attribute = SchemaAttribute.new(:id, cast_type: :string)
        assert_equal(String, schema_attribute.value { @context.new }.class)
      end

      def test_value_is_castable_to_integer
        schema_attribute = SchemaAttribute.new(:user_profile_id,
                                               cast_type: :integer,
                                               value_before_read: "metadata.user_profile_id")

        assert_equal(Integer, schema_attribute.value { @context.new }.class)
      end

      def test_value_is_castable_to_float
        schema_attribute = SchemaAttribute.new(:hour_rate,
                                               cast_type: :float,
                                               value_before_read: "metadata.hour_rate")

        assert_equal(Float, schema_attribute.value { @context.new }.class)
      end

      def test_value_is_castable_to_big_decimal
        schema_attribute = SchemaAttribute.new(:hour_rate,
                                               cast_type: :big_decimal,
                                               value_before_read: "metadata.hour_rate")

        assert_equal(BigDecimal, schema_attribute.value { @context.new }.class)
      end

      def test_value_is_castable_to_array
        schema_attribute = SchemaAttribute.new(:metadata, cast_type: :array)
        assert_equal(Array, schema_attribute.value { @context.new }.class)
      end

      def test_value_is_castable_to_hash
        schema_attribute = SchemaAttribute.new(:first_name,
                                               cast_type: :hash,
                                               value_before_read: -> { [:first_name, data[:first_name]] })

        assert_equal(Hash, schema_attribute.value { @context.new }.class)
      end
    end
  end
end
