# -*- coding: utf-8 -*-

# Zamiast Google image graph api
# użyć biblioteki JavaScript [dygraphs](http://dygraphs.com/)

require 'json'                     # zbędne w Rails
require 'active_support/core_ext'  # ditto
require 'net/http'                 # Ruby Standard Library
require 'geo-distance'             # dopisać gem 'geo-distance' do Gemfile

# Dokumentacja:
#
#   http://www.ruby-doc.org/stdlib/
#   http://rubydoc.info/gems/geo-distance/0.2.0/frames
#
#   albo geo_calc:
#       http://rubydoc.info/gems/geo_calc/0.7.6/frames

# https://github.com/chneukirchen/styleguide/blob/master/RUBY-STYLE

class Elevation

  ELEVATION_BASE_URL = 'http://maps.googleapis.com/maps/api/elevation/json'

  attr_accessor :locations, :track, :profile, :distance, :highest, :lowest, :uri

  def initialize(opts={})
    @options = {
      # Google Earth: Kuźnice            |Kasprowy Wierch
      :locations  => "49.269604,19.980100|49.232362,19.981650",
      :samples    => 4,
      :sensor     => false
    }.merge!(opts)
    @locations = @options.delete(:locations)
    @options[:path] = @locations # API Google: w uri ma być 'path' a nie 'locations'

    set_profile_and_track_and_uri

    @distance = GeoDistance::Haversine.geo_distance(*two_adjacent_points_from_track).kms *
      (@options[:samples]-1)

    @highest = @profile.max
    @lowest  = @profile.min
  end

  private

  def set_profile_and_track_and_uri
    @uri = "#{ELEVATION_BASE_URL}?#{@options.to_query}"
    response = Net::HTTP.get_response(URI.parse(@uri))

    # if response.code == "200"
    #   puts "This URI works: #{uri}"
    # else
    #   puts "TODO: wstawić jakąś trasę – po jakimś południku?"
    # end

    @track = JSON.parse(response.body)['results']
    @profile = @track.map do |x|
      x['elevation'].to_i
    end
  end

  def two_adjacent_points_from_track
    return @track[0]['location']['lng'],
        @track[0]['location']['lat'],
        @track[1]['location']['lng'],
        @track[1]['location']['lat']
  end

end



