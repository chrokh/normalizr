module Normalizr
  class ArrayOf

    def initialize schema
      @schema = schema
    end

    def visit obj, bag
      Array(obj).map { |item| @schema.visit(item, bag) }
    end

    def unvisit obj, ids
      ids.map { |id| @schema.unvisit(obj, id) }
    end

  end
end
