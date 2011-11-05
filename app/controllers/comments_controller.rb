class CommentsController < ApplicationController

  before_filter do
    @trail = Trail.find(params[:trail_id])
  end

  def create
    @comment = @trail.comments.build(params[:comment])
    @comment.save
    respond_with(@trail, @comment, :location => @trail)
  end

  def destroy
    @comment = @trail.comments.find(params[:id])
    @comment.destroy
    respond_with(@trail, @comment, :location => @trail)
  end

  def edit
  @comment = @trail.comments.find(params[:id])
end

def update
  @comment = @trail.comments.find(params[:id])
  @comment.update_attributes(params[:comment])
  respond_with(@trail, @comment, :location => @trail)
end

end
