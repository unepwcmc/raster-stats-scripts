#!/usr/bin/ruby
require 'rubygems'
require 'net/http'
require 'optparse'
require 'json'
require 'pp'

module Raster_stats_query_module

  class Q
    def initialize options
      @options = options
      @options_clone = options.clone
      @all_countries_accumulator = []
      json = File.read('iso2_codes.json')
      @iso2_codes = JSON.parse(json, :symbolize_names => true)
    end

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
      tot = 0
      percentage_object_list.each{|obj| tot += obj[:value]}
      percentage_object_list.each{|obj| 
        obj[:percentage] = obj[:value] / tot * 100
      }
      percentage_object_list
    end

    def start_queries
      unless @options_clone.operation == "percentage"
        @options_clone.raster_id = @options.raster_ids[0]
        if @options_clone.country
          pp execute_query @options_clone
        else
          @iso2_codes.each do |feature|
            @options_clone.country = feature[:alpha_2]
            res = execute_query @options_clone
            if res
              res[:iso2] = @options_clone.country
              @all_countries_accumulator << res
            end
          end
          pp @all_countries_accumulator
        end
      else
        # Relying on a few assumptions here:
        # a percentage calculation expects a list of rasters...
        # the rasters should all have values 1 or 0...
        @options.operation = "sum"
        if @options.country
          pp get_percentage_object_list @options
        else
          @iso2_codes.each do |feature|
            @all_countries_accumulator << get_percentage_object_list(
              @options)
          end
          pp @all_countries_accumulator
        end
      end
    end

  end
end