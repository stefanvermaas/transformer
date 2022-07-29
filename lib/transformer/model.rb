# frozen_string_literal: true

module Transformer
  class Model
    attr_reader :data

    def initialize(data)
      @data = data
    end

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
  end
end
