# -*- coding: utf-8 -*-

#require 'rubygems'
require 'json'
require 'net/http'
require 'uri'

require 'active_support/core_ext'
require 'geo-distance'

# zobacz https://github.com/winston/google_visualr
# require 'google_visualr'



# https://github.com/chneukirchen/styleguide/blob/master/RUBY-STYLE

class Elevation

  ELEVATION_BASE_URL = 'http://maps.googleapis.com/maps/api/elevation/json'
  CHART_BASE_URL = 'http://chart.apis.google.com/chart'

  attr_accessor :elevation_array

  def initialize(opts={})
    @elvtn_args = {
      :path => "49.2710,19.9813|49.2324,19.9817",
      :samples => 30,
      :sensor => false
    }.merge!(opts)
  end

  def get_chart(opts={})
    #
    # http://code.google.com/intl/pl-PL/apis/chart/image/
    # http://code.google.com/intl/pl-PL/apis/chart/image/docs/chart_params.html
    # http://code.google.com/intl/pl-PL/apis/chart/image/docs/post_requests.html
    #
    chart_args = {
      :cht   => "lc",
      :chs   => "650x300",
      # optional margins
      :chma  => "0,0,0,0|80,20", # nie działa -- dlaczego?
      # optional args
      :chtt  => "Title",
      :chts  => "AA0000,12,c", # 12 == font size
      :chxt  => 'x,y',
      :chxr  => '1,1000,2500', # 0 == x-axis, 1 == y-axis
      :chds  => "1000,2500",
      :chxl  => "0:|Elevation",
      :chxp  => "0,50", # 0 == x-axis, 50 == center
      :chco  => "A66C48",
      :chls  => "2", # line thickness
      :chm   => "B,BF8C60,0,0,0"
   #   :chm   => "B,76A4FB,0,0,0" # blue fills under the line
    }.merge!(opts)

    get_elevation_array

    dataString = 't:' + @elevation_array.join(',')
    chart_args[:chd] = dataString;
    url = URI.escape "#{CHART_BASE_URL}?#{chart_args.to_query}"
  end

  def get_min
    @elevation_array.min
  end

  def get_max
    @elevation_array.max
  end


  private

  def get_elevation_array
    url = URI.escape "#{ELEVATION_BASE_URL}?#{@elvtn_args.to_query}"
    response = Net::HTTP.get_response(URI.parse(url))
    response_array = JSON.parse(response.body)['results']

    @elevation_array = response_array.map do |x|
      x['elevation'].to_i
    end
  end

end
