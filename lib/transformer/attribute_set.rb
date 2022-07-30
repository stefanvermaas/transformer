# frozen_string_literal: true

require "json"

module Transformer
  class AttributeSet
    def initialize(context)
      @context = context
      @attributes = context.attributes
    end

    def to_h
      @attributes.each_with_object({}) do |attribute, hash|
        hash[attribute.name] = attribute.value { @context }
      end
    end

    def to_json(**options)
      JSON.generate(to_h, **options)
    end
  end
end
