module Normalizr
  class Schema

    def initialize name, definition={}
      @name = name
      @definition = definition
    end

    def visit obj, bag
      relationships = @definition.keys.map do |key|
        id = @definition[key].visit(obj[key], bag)
        Hash[key, id]
      end.reduce({}, &:merge)

      bag.add(@name, obj.merge(relationships))
    end

  end
end
