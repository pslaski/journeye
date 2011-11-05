class TrailsController < ApplicationController
  # GET /trails
  def index
    @trails = Trail.search(params[:search]).order("name").page(params[:page]).per(5)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /trails/1
  def show
    @trail = Trail.find(params[:id])
    @comment = Comment.new

    respond_with(@trail)
  end

  # GET /trails/new
  def new
    @trail = Trail.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /trails/1/edit
  def edit
    @trail = Trail.find(params[:id])
  end

  # POST /trails
  def create
    @trail = Trail.new(params[:trail])

    @elevation = ::Elevation.new(:samples => 40, :locations => "#{@trail.locations}")
    @trail.distance = @elevation.distance
    @trail.highest = @elevation.highest
    @trail.lowest = @elevation.lowest
    @trail.uri = @elevation.uri
    @trail.chart_uri = elevation_chart_uri @elevation.profile, @elevation.distance, :chtt => "#{@trail.name}", :chxl => "0:|profil trasy", :chs => "800x375"
    @trail.img_uri = staticmap_uri @elevation.locations, :size => "640x400"

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

    @elevation = ::Elevation.new(:samples => 40, :locations => "#{params[:trail].locations}")
    @trail.distance = @elevation.distance
    @trail.highest = @elevation.highest
    @trail.lowest = @elevation.lowest
    @trail.uri = @elevation.uri
    @trail.chart_uri = elevation_chart_uri @elevation.profile, @elevation.distance, :chtt => "#{@trail.name}", :chxl => "0:|profil trasy", :chs => "800x375"
    @trail.img_uri = staticmap_uri @elevation.locations, :size => "640x400"

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
