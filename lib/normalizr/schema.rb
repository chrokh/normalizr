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
      # TODO: Write test for why this conditional needs to be here.
      # I believe it has something to do with whether the root keys
      # are originally symbols or non-symbols.

      unless obj.include? @name.to_s.to_sym
        raise ArgumentError.new("Type '#{@name}' does not exist but foreign key '#{id}' was found")
      end

      normalized = (obj[@name.to_s.to_sym][id] || obj[@name.to_s.to_sym][id.to_s.to_sym])

      if normalized.nil?
        raise ArgumentError.new("Type '#{@name}' does not contain record with key '#{id}'")
      end

      denormalized = @definition.keys.map do |key|
        value = @definition[key].unvisit(obj, normalized[key])
        Hash[key, value]
      end.reduce({}, &:merge)

      normalized.merge(denormalized)
    end


  end
end
