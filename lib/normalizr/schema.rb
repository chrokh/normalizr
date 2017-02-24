module Normalizr
  class Schema


    def initialize name, definition={}
      @name = name
      @definition = definition
    end


    def visit obj, bag
      if obj.is_a? Hash
        relationships = @definition.keys.map do |key|
          id = @definition[key].visit(obj[key], bag)
          Hash[key, id]
        end.reduce({}, &:merge)

        bag.add(@name, obj.merge(relationships))
      end
    end


    def unvisit obj, id
      normalized = obj[@name.to_sym][id]

      denormalized = @definition.keys.map do |key|
        value = @definition[key].unvisit(obj, normalized[key])
        Hash[key, value]
      end.reduce({}, &:merge)

      normalized.merge(denormalized)
    end


  end
end
