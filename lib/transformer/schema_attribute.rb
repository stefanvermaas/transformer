# frozen_string_literal: true

module Transformer
  class SchemaAttribute
    attr_reader :name

    def initialize(name)
      @name = name.to_sym
    end

    def ==(other)
      name == other.name
    end
    alias eql? ==
  end
end
