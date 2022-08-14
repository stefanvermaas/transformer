# frozen_string_literal: true

module Transformer
  # The `Transformer::Model` allows building descriptive data transformations.
  #
  # Each `Transformer::Model` will need to implement a `Transformer::SchemaDefinition`
  # with the provided schema DSL. To utilize the schema DSL, the `schema` block
  # needs to be defined and attributes need to be added.
  #
  # @example schema to map a field one-on-one
  #   class ProductMapper < Transformer::Model
  #     schema do
  #       attribute :name
  #     end
  #   end
  #
  # However, a `Transformer::Model` will also need to get input data to be able to
  # do the transformations and build an output.
  #
  # @example input data for data transformations
  #
  #   $ ProductMapper.new({
  #       name: "Travel Bag",
  #       unit_price: 100.00,
  #       quantity: "2",
  #       metadata: {
  #         customer: {
  #           id: "625808ac-bf40-44ed-b4e2-e69a5f91f5ff",
  #           first_name: "Jane",
  #           last_name: "Doe"
  #         }
  #       }
  #     })
  #
  # When building data transformations, one will can cast values from one type to
  # another one. To do so, one can use the build-in cast values. The supported
  # cast types are: string, integer, float, bigdecimal, hash, and array.
  #
  # @example schema to cast a string to an integer
  #
  #   class ProductMapper < Transformer::Model
  #     schema do
  #       attribute :quantity, type: :integer
  #     end
  #   end
  #
  # When the keys of the initial data object aren't aligned with the desired output,
  # one can tell the `Transformer::Model` where to find the key. This is the most
  # simplistic data transformation.
  #
  # @example schema to change the output key for a specific input key
  #
  #   class ProductMapper < Transformer::Model
  #     schema do
  #       attribute :price, value: :unit_price
  #     end
  #   end
  #
  # The `Transformer::Model` also supports retrieving nested attributes from a
  # hash data object. To be able to do so, one should define the path to the
  # input value.
  #
  # @example schema to find a nested key
  #
  #   class ProductMapper < Transformer::Model
  #     schema do
  #       attribute :customer_id, value: "metadata.customer.id"
  #     end
  #   end
  #
  # The `Transformer::Model` also supports more advanced ways to access and transform
  # data through instance methods and procs. Both methods have direct access to the input data.
  #
  # @example schema with an instance method lookup
  #
  #   class ProductMapper < Transformer::Model
  #     schema do
  #       attribute :customer_name, value: :reverse_customer_name
  #     end
  #
  #     def reverse_customer_name
  #       [data[:first_name], data[:last_name]].join(" ").reverse
  #     end
  #   end
  #
  # @example schema with an inline lookup (through a Proc)
  #
  #   class ProductMapper < Transformer::Model
  #     schema do
  #       attribute :name, value: -> { [data[:first_name], data[:last_name]].join(" ") }
  #     end
  #   end
  #
  class Model
    attr_reader :data

    class << self
      attr_reader :schema_definition

      def schema(&block)
        if block_given?
          @schema_definition ||= SchemaDefinition.new
          @schema_definition.instance_exec(&block)
        end

        self
      end
    end

    def initialize(data)
      @data = data
    end

    # Transforms data into a hash.
    #
    # @params options [Hash] Options for the transformer model.
    # @return [Hash]
    def to_h(**options)
      attribute_set.to_h(**options)
    end

    # Transform data into a JSON hash.
    #
    # @param options [Hash] Options for the transformer model and JSON parser.
    # @return [String]
    def to_json(**options)
      attribute_set.to_json(**options)
    end

    private

    def attribute_set
      @attribute_set ||= AttributeSet.new(
        self,
        self.class.schema_definition
      )
    end
  end
end
