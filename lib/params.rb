require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  #
  # You haven't done routing yet; but assume route params will be
  # passed in as a hash to `Params.new` as below:
  def initialize(req, route_params = {})
    to_parse = req.query_string.to_s + req.body.read.to_s
    @params = route_params.merge(parse_www_encoded_form(to_parse))
  end

  def [](key)
    @params[key.to_s]
  end

  def to_s
    @params.to_json.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    return {} if www_encoded_form.nil?

    params = {}
    kv_pairs = URI::decode_www_form(www_encoded_form)
    kv_pairs.map! { |key, val| [parse_key(key), val] }

    kv_pairs.each do |keys, val|
      last_hash = params
      keys.each do |key|
        if key.equal?(keys.last)
          last_hash[key] = val
        else
          last_hash[key] ||= {}
          last_hash = last_hash[key]
        end
      end
    end

    params
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end
