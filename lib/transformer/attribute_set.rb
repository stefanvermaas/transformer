# frozen_string_literal: true

require "json"

module Transformer
  # The `Transformer::AttributeSet` builds the outputs for a `Transformer::Model`
  # based on information from the `Transformer::SchemaDefinition`.
  class AttributeSet
    def initialize(context, schema_definition)
      @context = context
      @schema_definition = schema_definition
    end

    # Transforms the `Transformer::Model` to a hash based on the defined schema.
    #
    # @example transformation for only a few attributes
    #
    #   class UserMapping < Transformer::Model
    #     schema do
    #       attribute :first_name
    #       attribute :last_name
    #     end
    #   end
    #
    #   $ user_mapping = UserMapping.new({ first_name: "Jane", last_name: "Doe" })
    #   $ user_mapping.to_h(only: :first_name)
    #   => { first_name: "Jane" }
    #
    # @example transformation with all attributes except some
    #
    #   $ user_mapping.to_h(except: :first_name)
    #   => { last_name: "Jane" }
    #
    # @param options [Hash] A list of options for serialization (e.g. :only or :except).
    # @return [Hash]
    def to_h(**options)
      attribute_names_for_serialization = attribute_names

      if options[:only]
        attribute_names_for_serialization &= Array(options[:only]).map(&:to_sym)
      elsif options[:except]
        attribute_names_for_serialization -= Array(options[:except]).map(&:to_sym)
      end

      attributes_for_serialization = attribute_cache.slice(*attribute_names_for_serialization)
      read_and_cache_attributes!(attributes_for_serialization)
    end

    # Transforms the `Transformer::Model` to a JSON string based on the defined schema.
    #
    # NOTE: The serialization options can also include options for the JSON serializer
    # and for the `Transformer::AttributeSet#to_h` method.
    #
    # @param options [Hash] A list of serialization options for serialization.
    # @return [String]
    def to_json(**options)
      filter_options = options.slice(:only, :except)
      json_options = options.except(:only, :except)

      JSON.generate(to_h(**filter_options), **json_options)
    end

    private

    def attribute_cache
      @attribute_cache ||= @schema_definition.each_with_object({}) do |attribute, hash|
        hash[attribute.name] = attribute
      end
    end

    def attribute_names
      @attribute_names ||= attribute_cache.keys
    end

    def read_and_cache_attributes!(attributes_for_serialization)
      attributes_for_serialization.transform_values! do |attribute|
        attribute.is_a?(SchemaAttribute) ? attribute.value { @context } : attribute
      end
    end
  end
end
