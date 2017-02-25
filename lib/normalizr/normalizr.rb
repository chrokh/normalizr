require 'normalizr/bag'

module Normalizr

  def self.normalize! obj, schema, opts={}
    bag = Normalizr::Bag.new(opts)

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
          if obj[key].nil? || obj[key].is_a?(Array)
            hash[key] = {}
          else
            hash[key] = obj[key]
          end
        end
      end
    end

    hash
  end


  def self.denormalize! obj, schema, id=nil
    schema.keys.map do |key|
      if id.nil?
        if obj[key].is_a? Hash
          value = schema[key].unvisit(obj, obj[key].keys)
        else
          value = (obj[key] || [])
        end
      else
        value = schema[key].unvisit(obj, Array(id))
      end
      Hash[key, value]
    end.reduce({}, &:merge)
  end

end
