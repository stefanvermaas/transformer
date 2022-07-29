# frozen_string_literal: true

module Transformer
  class SchemaDefinition
    def initialize
      @attributes = []
    end

    def attribute(name)
      @attributes |= [SchemaAttribute.new(name)]
    end

    def attributes(*names, **kwargs)
      return @attributes if names.empty?

      names.each { |name| attribute(name, **kwargs) }
    end
  end
end
