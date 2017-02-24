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

    bag.to_hash
  end


  def self.denormalize! obj, schema
    schema.keys.map do |key|
      value = schema[key].unvisit(obj, obj[key].keys)
      Hash[key, value]
    end.reduce({}, &:merge)
  end

end
