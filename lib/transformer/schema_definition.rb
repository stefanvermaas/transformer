# frozen_string_literal: true

module Transformer
  # The `Transformer::SchemaDefinition` collects all information about the schema
  # of the `Transformer::Model` and its attributes.
  class SchemaDefinition
    include Enumerable

    def initialize
      @attributes = []
    end

    # Adds a single attribute to the `Transformer::SchemaDefinition` for the data
    # transformer class.
    #
    # @name [String|Symbol] The name for the key in the output hash.
    # @options [Hash] A list of options for the attribute (e.g. type and value).
    # @return [Array]
    def attribute(name, **options)
      @attributes |= [
        SchemaAttribute.new(
          name,
          cast_type: options[:type],
          value_before_read: options[:value]
        )
      ]
    end

    # Adds a list of attributes to the `Transformer::SchemaDefinition` and uses
    # the same set of options for each attribute. Ideal for mass-assignment.
    #
    # @param names [Array] A list of attribute names.
    # @param options [Hash] A list of options for the attribute (e.g. type and value).
    # @return [Array]
    def attributes(*names, **options)
      names.each { |name| attribute(name, **options) }
    end

    def each(&block)
      @attributes.each(&block)
    end

    def include?(attribute)
      @attributes.include?(attribute)
    end

    def size
      @attributes.size
    end
    alias length size
    alias count size
  end
end
