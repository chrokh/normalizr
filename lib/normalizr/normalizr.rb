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
end
