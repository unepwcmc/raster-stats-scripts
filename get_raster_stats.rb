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
  options.raster_ids = [1] # carbon
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
    opts.on("-i", "--ids [INTEGER]", Array, 
            "Comma separated list of Raster ids",
            "  If more than one, operation must be percentage") do |raster_ids|
      options.raster_ids = raster_ids
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


def execute_query options
  uri = URI("#{ options.url_root }rasters/#{ options.raster_id }/" + 
            "operations/#{ options.operation }")
  params = { :iso2 => options.country }
  uri.query = URI.encode_www_form(params)
  begin
    res = Net::HTTP.get_response(uri)
  rescue  Exception => e  
    pp options.country, e.message
  end
  #puts res.body if res.is_a?(Net::HTTPSuccess)
  begin
    JSON.parse(res.body, :symbolize_names => true)
  rescue
    pp "Error for #{options.country}"
    nil
  end
end

def get_percentage_object_list options
  percentage_object_list = []
  opt = options.clone
  options.raster_ids.each do |raster_id|
    opt.raster_id = Integer(raster_id)
    res = execute_query opt
    if res
      res[:iso2] = opt.country
      res[:raster_id] = raster_id
      percentage_object_list << res
    end
  end
  percentage_object_list
  tot = 0
  percentage_object_list.each{|obj| tot += obj[:value]}
  percentage_object_list.each{|obj| 
    obj[:percentage] = obj[:value] / tot * 100
  }
  percentage_object_list
end

opt = options.clone
all_countries_accumulator = []

unless opt.operation == "percentage"
  opt.raster_id = options.raster_ids[0]
  if opt.country
    pp execute_query opt
  else
    iso2_codes.each do |feature|
      opt.country = feature[:alpha_2]
      res = execute_query opt
      if res
        res[:iso2] = opt.country
        all_countries_accumulator << res
      end
    end
    pp all_countries_accumulator
  end
else
  # Relying on a few assumptions here:
  # a percentage calculation expects a list of rasters...
  options.operation = "sum"
  if options.country
    pp get_percentage_object_list options
  else
    iso2_codes.each do |feature|
      all_countries_accumulator << get_percentage_object_list(options)
    end
    pp all_countries_accumulator
  end
end