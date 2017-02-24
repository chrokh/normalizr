require 'normalizr/bag'

module Normalizr

  def self.normalize! obj, schema
    bag = Normalizr::Bag.new

    if schema.is_a? Hash
      schema.keys.each do |key|
        schema[key].visit(obj[key], bag)
      end
    else
      schema.visit(obj, bag)
    end

    hash = bag.to_hash

    if schema.is_a? Hash
      schema.keys.each do |key|
        unless hash.has_key? key
          hash[key] = {}
        end
      end
    end

    hash
  end


  def self.denormalize! obj, schema, id=nil
    schema.keys.map do |key|
      if id.nil?
        value = schema[key].unvisit(obj, obj[key].keys)
      else
        value = schema[key].unvisit(obj, Array(id))
      end
      Hash[key, value]
    end.reduce({}, &:merge)
  end

end
