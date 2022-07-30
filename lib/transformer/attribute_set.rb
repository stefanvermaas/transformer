# frozen_string_literal: true

require "json"

module Transformer
  class AttributeSet
    def initialize(context)
      @context = context
      @attributes = context.attributes
    end

    def attribute_names
      _attributes.keys
    end

    def to_h(**options)
      attribute_names_for_serialization = attribute_names

      if options[:only]
        attribute_names_for_serialization &= Array(options[:only]).map(&:to_sym)
      elsif options[:except]
        attribute_names_for_serialization -= Array(options[:except]).map(&:to_sym)
      end

      read_attributes(attribute_names_for_serialization)
    end

    def to_json(**options)
      JSON.generate(to_h, **options)
    end

    private

    def _attributes
      @_attributes ||=
        @attributes.each_with_object({}) do |attribute, hash|
          hash[attribute.name] = attribute
        end
    end

    def read_attributes(attribute_names_for_serialization)
      _attributes.slice(*attribute_names_for_serialization).transform_values do |attribute|
        attribute.value { @context }
      end
    end
  end
end
