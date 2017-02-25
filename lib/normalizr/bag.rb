require 'securerandom'

module Normalizr
  class Bag
    def initialize bag={}, opts
      @bag = bag
      @opts = opts
    end

    def add name, value
      if value[:id].nil? || @opts[:new_keys]
        value[:id] = next_guid!
      end
      @bag[name.to_sym] ||= {}
      @bag[name.to_sym][value[:id]] = value
      value[:id]
    end

    def get name, id
      @bag[name.to_sym][id]
    end

    def to_hash
      @bag.dup
    end

    def next_guid!
      SecureRandom.uuid
    end
  end
end
