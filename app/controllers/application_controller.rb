require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  protect_from_forgery

    # ----------------------------------------------------------------
  # Czy elevation_chart_uri i staticmap_uri to metody pomocnicze ?
  #
  # Wkleić kod metod oraz dopisać do aplication_controller.rb:
  #
   helper_method :elevation_chart_uri, :staticmap_uri

  # http://www.damnhandy.com/2011/01/18/url-vs-uri-vs-urn-the-confusion-continues/

  def elevation_chart_uri(profile, distance, opts={})
    chart_base_url = 'http://chart.apis.google.com/chart'
    #
    # http://code.google.com/intl/pl-PL/apis/chart/image/
    # http://code.google.com/intl/pl-PL/apis/chart/image/docs/chart_params.html
    # http://code.google.com/intl/pl-PL/apis/chart/image/docs/post_requests.html

    margins = 30 # zgrubne przybliżenie; z gimpa
    width = (distance * (200/(1.5 * 2))).to_i + margins  # 1.5 = 1500 m
    chs = "#{width}x#{200}"

    chart_args = {
      :cht   => "lc",
      :chs   => chs,
      # optional margins
      :chma  => "0,0,0,0|0,0", # nie działa dolny margines -- dlaczego?
      # optional args
      :chtt  => "Title",
      :chts  => "AA0000,12,c", # 12 == font size
      :chxt  => 'x,y',
      :chxr  => '1,1000,2500', # 0 == x-axis, 1 == y-axis
      :chds  => "1000,2500",
      :chxl  => "0:|Elevation",
      :chxp  => "0,50", # 0 == x-axis, 50 == center
      :chco  => "0000FF",
      :chls  => "4", # line thickness
      :chm   => "B,76A4FB,0,0,0" # blue fills under the line
    }.merge!(opts)
    chart_args[:chd] = 't:' + profile.join(',')

    return "#{chart_base_url}?#{chart_args.to_query}"
  end


  def staticmap_uri(locations, opts={})
    map_base_url = 'http://maps.googleapis.com/maps/api/staticmap'
    #
    # http://code.google.com/intl/pl-PL/apis/maps/documentation/staticmaps/

    # The Google Static Maps API creates maps in several formats, listed below:
    # * roadmap (default)
    # * satellite
    # * terrain
    # * hybrid

    # ?maptype=roadmap
    # &size=640x400
    # &markers=color:green|label:S|latitude,longitude
    # &markers=color:red|label:F|latitude,longitude
    # &sensor=false

    # locations == 49.2710,19.9813|49.2324,19.9817
    locs = locations.split("|")

    map_args = {
      :maptype => "terrain",
      :size => "400x400",
      :markers => [
          "color:green|label:S|#{locs[0]}", "color:red|label:F|#{locs[1]}"
        ],
      :sensor => false
    }.merge!(opts)

    return "#{map_base_url}?#{map_args.to_query}".gsub(/%5B%5D/, "") # remove []

  end
end
