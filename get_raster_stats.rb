#!/usr/bin/ruby
require 'rubygems'
require 'net/http'
require 'optparse'
require 'json'
require 'pp'

json = File.read('iso2_codes.json')
iso2_codes = JSON.parse(json, :symbolize_names => true)

def parse(args)
  options = OpenStruct.new
  options.url_root = "http://raster-stats.unep-wcmc.org/"
  options.raster_id = 3 # carbon
  options.operation = "count"
  options.country = nil
  
  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: get_raster_stats.rb [options]"
  
    opts.separator ""
    opts.separator "Specific options:"
  
    opts.on("-u", "--url_root [STRING]", String, 
            "Url root to raster-stats service (optional)",
            "  defaults to http://raster-stats.unep-wcmc.org/") do |url_root|
      if url_root
        options.url_root = url_root
      end
    end
    opts.on("-i", "--id [INTEGER]", Integer, "Raster id") do |id|
      options.id = id
    end
    opts.on("-o", "--operation [STRING]", String, 
            "Name of the statistical operation, choose from:",
            "  avg, sum, min, max, percentage") do |operation|
      options.operation = operation
    end
    opts.on("-c", "--country [STRING]", String, 
            "Iso2 country code (optional)",
            "  if omitted it calculates stats for all countries") do |country|
      options.country = country || nil
    end
  end
  opt_parser.parse!(args)
  options
end

options = parse(ARGV)


def execute_query country, options
  uri = URI("#{ options.url_root }rasters/#{ options.id }/" + 
            "operations/#{ options.operation }")
  params = { :iso2 => country }
  uri.query = URI.encode_www_form(params)
  begin
    res = Net::HTTP.get_response(uri)
  rescue  Exception => e  
    pp country, e.message
  end
  #puts res.body if res.is_a?(Net::HTTPSuccess)
  begin
    JSON.parse(res.body, :symbolize_names => true)
  rescue
    pp "Error for #{country}"
    nil
  end
end

all_countries_accumulator = []

unless options.operation == "percentage"
  country = options.country
  if country
    execute_query country, options
  else
    iso2_codes.each do |feature|
      country = feature[:alpha_2]
      res = execute_query country, options   
      if res
        res[:iso2] = country
        all_countries_accumulator << res
        pp res
      end
    end
    pp all_countries_accumulator
  end
else
  if country
    #options.operation = ""
    #res_one = execute_query country, options
    pp "percentage to be implemented"
  else
    pp "percentage for all countries to be implemented"
  end
end