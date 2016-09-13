module Normalizr
  class ArrayOf

    def initialize schema
      @schema = schema
    end

    def visit obj, bag
      Array(obj).map { |item| @schema.visit(item, bag) }
    end

  end
end
