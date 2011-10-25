class TrailsController < ApplicationController
  # GET /trails
  def index
    @trails = Trail.all
  end

  # GET /trails/1
  def show
    @trail = Trail.find(params[:id])
     @map = Cartographer::Gmap.new( 'map' )
  @map.zoom = :bound
  @map.icons << Cartographer::Gicon.new


  marker1 = Cartographer::Gmarker.new(:name=> "Marker1", :marker_type => "Building",
              :position => [@trail.latitude_start.to_f, @trail.longitude_start.to_f],
              :info_window_url => "/url_for_info_content")
  marker2 = Cartographer::Gmarker.new(:name=> "Marker2", :marker_type => "Building",
              :position => [@trail.latitude_end.to_f, @trail.longitude_end.to_f],
              :info_window_url => "/url_for_info_content")

  @map.markers << marker1
  @map.markers << marker2
  end

  # GET /trails/new
  def new
    @trail = Trail.new


  end

  # GET /trails/1/edit
  def edit
    @trail = Trail.find(params[:id])
  end

  # POST /trails
  def create
    @trail = Trail.new(params[:trail])

    @elevation = ::Elevation.new(:path => @trail.longitude_start + "," + @trail.latitude_start + "|" + @trail.longitude_end + "," + @trail.latitude_end)

    @trail.map_url= Elevation.elevation_chart_uri(@elevation)

    respond_to do |format|
      if @trail.save
        format.html { redirect_to @trail, notice: 'Trail was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /trails/1
  def update
    @trail = Trail.find(params[:id])

    respond_to do |format|
      if @trail.update_attributes(params[:trail])
        format.html { redirect_to @trail, notice: 'Trail was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /trails/1
  def destroy
    @trail = Trail.find(params[:id])
    @trail.destroy

    respond_to do |format|
      format.html { redirect_to trails_url }
    end
  end
end
