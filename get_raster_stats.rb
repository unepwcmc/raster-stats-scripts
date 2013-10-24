#!/usr/bin/ruby
require 'rubygems'
require 'net/http'
require 'optparse'
require 'json'
require 'pp'


options = OpenStruct.new
options.raster_id = 3 # carbon
options.operation = "count"
options.country = ''

opt_parser = OptionParser.new do |opts|
  opts.banner = "Usage: get_raster_stats.rb [options]"

  opts.separator ""
  opts.separator "Specific options:"

  opts.on("-i", "--id [INTEGER]", Integer, "Raster id") do |id|
    options.id = id
  end
  opts.on("-o", "--operation [STRING]", String, 
          "Name of the statistical operation, choose from:",
          "  avg, sum, min, max") do |operation|
    options.operation = operation
  end
  opts.on("-c", "--country [STRING]", String, 
          "Iso2 country code (optional)",
          "  if omitted it calculates stats for all countries") do |country|
    options.country = country || ''
  end
end

options = opt_parser.parse(ARGV)
