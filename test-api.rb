require 'sinatra/base'
require 'json'
require 'open-uri'

BASE_URI    = 'http://webservice.recruit.co.jp/rikunabi-next'
FORMAT_JSON = 'format=json'

class ApiTest < Sinatra::Base
  helpers do
    def puts_json_record(json)
      ret = ""
      case json
      when Hash
        ret += puts_hash(json)
      when Array
        ret += puts_array(json)
      else
        ret += "<h2>#{json}</h2>"
      end
    end

    private
    def puts_hash(json)
      ret = "<dl>"
      json.each do |key, val|
        ret += "<dt>#{key}:</dt><dd>"
        case val
        when Hash
          ret += puts_hash(val)
        when Array
          ret += puts_array(val)
        else
          ret += "#{val}"
        end
      end
      return ret += "</dd></dl>"
    end

    def puts_array(records)
      ret = "<ol><li>"
      records.each do |record|
        case record
        when Hash
          ret += puts_hash(record)
        when Array
          ret += puts_array(record)
        else
          ret += "<p style='color:red'>#{record}</p>"
        end
      end
      ret += "</li></ol>"
    end
  end

  get '/' do
    @secret_key = nil
    @api_type = "job"
    @key_list = "kikaku=01&start_from=2000-1-1"
    erb :index
  end

  post '/' do
    @secret_key = params["secret_key"]
    @api_type = params["api_type"]
    @key_list = params["key_list"]
    uri = "#{BASE_URI}/#{@api_type}/v1/pro?&key=#{@secret_key}&#{FORMAT_JSON}"

    if @key_list
      uri = "#{uri}&#{@key_list}"
    end

    @result = JSON.parse(open(uri).read)
    erb :index
  end

  run!
end

