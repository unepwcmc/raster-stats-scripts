#!/usr/bin/ruby
require 'rubygems'
require 'net/http'
require 'optparse'
require 'json'
require 'pp'

require './raster_stats_query_module'


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

q = Raster_stats_query_module::Q.new(options)
q.start_queries




