# -*- coding: utf-8 -*-


# Zamiast Google image graph api
# użyć biblioteki JavaScript [dygraphs](http://dygraphs.com/)

require 'rubygems'
require 'json'
require 'net/http'
require 'uri'
require 'active_support/core_ext'
require 'geo-distance'

require 'pp'

# zobacz https://github.com/winston/google_visualr
# require 'google_visualr'


class Elevation

  ELEVATION_BASE_URL = 'http://maps.googleapis.com/maps/api/elevation/json'

  attr_accessor :array, :path, :distance, :highest, :lowest

  def initialize(opts={})
    @options = {
      :path => "49.2710,19.9813|49.2324,19.9817",
      :samples => 11,
      :sensor => false
    }.merge!(opts)
    set_path_and_array
    @highest = @array.max
    @lowest  = @array.min
    lon1 = @path[0]['location']['lng']
    lat1 = @path[0]['location']['lat']
    lon2 = @path[1]['location']['lng']
    lat2 = @path[1]['location']['lat']
    @distance = GeoDistance::Haversine.geo_distance(lat1,lon1,lat2,lon2).kms * (@options[:samples]-1)
  end

  # http://www.damnhandy.com/2011/01/18/url-vs-uri-vs-urn-the-confusion-continues/

  def self.elevation_chart_uri(elevation, opts={})
    chart_base_url = 'http://chart.apis.google.com/chart'
    #
    # http://code.google.com/intl/pl-PL/apis/chart/image/
    # http://code.google.com/intl/pl-PL/apis/chart/image/docs/chart_params.html
    # http://code.google.com/intl/pl-PL/apis/chart/image/docs/post_requests.html

    #width = (elevation.distance * (200/(1.5 * 2))).to_i  # 1.5 = 1500 m
    #chs = "#{width}x#{200}"

    chs = "600x200"

    chart_args = {
      :cht   => "lc",
      :chs   => chs,
      # optional margins
      :chma  => "0,0,0,0|80,20", # nie działa -- dlaczego?
      # optional args
      :chtt  => "Title",
      :chts  => "AA0000,12,c", # 12 == font size
      :chxt  => 'x,y',
      :chxr  => '1,0,500', # 0 == x-axis, 1 == y-axis
      :chds  => "0,500",
      :chxl  => "0:|Elevation",
      :chxp  => "0,50", # 0 == x-axis, 50 == center
      :chco  => "0000FF",
      :chls  => "4", # line thickness
      :chm   => "B,76A4FB,0,0,0" # blue fills under the line
    }.merge!(opts)
    chart_args[:chd] = 't:' + elevation.array.join(',')

    chart_base_url+'?'+chart_args.to_query
    #URI.escape "#{chart_base_url}?#{chart_args.to_query}"
  end

  private

  def set_path_and_array
    #url = URI.escape "#{ELEVATION_BASE_URL}?#{@options.to_query}"
    url = ELEVATION_BASE_URL+'?'+@options.to_query
    response = Net::HTTP.get_response(URI.parse(url))
    @path = JSON.parse(response.body)['results']
    @array = @path.map do |x|
      x['elevation'].to_i
    end
  end

end
