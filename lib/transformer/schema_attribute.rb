# frozen_string_literal: true

module Transformer
  class SchemaAttribute
    attr_reader :cast_type, :name, :value_before_read

    def initialize(name, cast_type: nil, value_before_read: nil)
      @name = name.to_sym
      @cast_type = cast_type.to_sym if cast_type
      @value_before_read = value_before_read || @name
    end

    # Extracts and casts the value from the data source. The given block is passed
    # to the extraction methods as the context.
    #
    # @example supply context to the `value` method.
    #
    #   class DataSource
    #     def data
    #       { email: "jane@example.com" }
    #     end
    #   end
    #
    #   $ schema_attribute = SchemaAttribute.new(:email)
    #   = > <Transformer::SchemaAttribute ... />
    #
    #   $ schema_attribute.value { DataSource.new }
    #   => "jane@example.com"
    #
    # @return [Any]
    def value
      return @value if defined?(@value)

      @value = extract_and_cast_value(yield) if block_given?
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

    def cast_value(value) # rubocop:disable Metrics/CyclomaticComplexity
      case @cast_type
      when :array then value.to_a
      when :big_decimal, :bigdecimal then BigDecimal(value)
      when :float then value.to_f
      when :hash then value.to_h { |item| [item[0], item[1]] }
      when :integer then value.to_i
      when :string then value.to_s
      else
        value
      end
    end

    def extract_and_cast_value(context)
      value_before_type_cast = extract_value_from_context(context)
      cast_value(value_before_type_cast)
    end

    def extract_value_from_context(context) # rubocop:disable Metrics/MethodLength
      case @value_before_read
      when Proc
        context.instance_exec(&@value_before_read)
      when String
        context.data.dig(*@value_before_read.split(".")) ||
          context.data.dig(*@value_before_read.split(".").map(&:to_sym))
      when Symbol
        if context.respond_to?(@value_before_read, true)
          context.send(@value_before_read)
        else
          context.data[@value_before_read]
        end
      end
    end
  end
end
