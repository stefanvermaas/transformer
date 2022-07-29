# frozen_string_literal: true

module Transformer
  class SchemaAttribute
    # The `Transformer` gem only supports several cast types. The `UnsupportedCastType`
    # is raised whenever the user attempts to add an unsupported cast type.
    class UnsupportedCastType < StandardError
      def initialize(unsupported_cast_type)
        super(
          "The :#{unsupported_cast_type} is not a supported cast type. " \
          "Make sure to use either one of the following cast types: #{SchemaAttribute::SUPPORTED_CAST_TYPES}"
        )
      end
    end

    attr_reader :cast_type, :name

    SUPPORTED_CAST_TYPES = %i[string integer float bigdecimal big_decimal hash array].freeze

    def initialize(name, cast_type: :string)
      @name = name.to_sym
      @cast_type = cast_type.to_sym

      validate_cast_type!
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

    private

    def validate_cast_type!
      raise UnsupportedCastType, @cast_type unless SUPPORTED_CAST_TYPES.include?(@cast_type)
    end
  end
end
