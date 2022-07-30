# frozen_string_literal: true

module Transformer
  class SchemaAttribute
    attr_reader :cast_type, :name

    def initialize(name, cast_type: nil)
      @name = name.to_sym
      @cast_type = cast_type.to_sym if cast_type
    end

    # The `#==` allows using the `Array#|` concatination assignment as under the hood,
    # Ruby will call `#==` on each of the `SchemaAttribute` before adding it to the array.
    #
    # @param other [SchemaAttribute] The attribute for comparison
    # @return [Boolean]
    def ==(other)
      name == other.name
    end
    alias eql? ==
  end
end
