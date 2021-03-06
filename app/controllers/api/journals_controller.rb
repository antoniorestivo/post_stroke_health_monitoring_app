class Api::JournalsController < ApplicationController
 def index
  @journals = Journal.all
  render "index.json.jb"
 end
 def show
  journal_id = params[:id]
  @journal = Journal.find_by(id: journal_id)
  render "show.json.jb"
 end
 def create
  @journal = Journal.new(
    user_id: params[:user_id],
    description: params[:description],
    image_url: params[:image_url],
    video_url: params[:video_url],
    health_routines: params[:health_routines],
    bp_avg: params[:bp_avg],
    bp_annotations: params[:bp_annotations],
    image_of_tongue: params[:image_of_tongue]
  )
  if @journal.save
    render "show.json.jb"
  else
    render json: {errors: @journal.errors.full_messages}, status: 422
  end
 end
 def update
   journal_id = params[:id]
   @journal = Journal.find_by(id: journal_id)
   
   
   @journal.description = params[:description] || @journal.description
   @journal.image_url = params[:image_url] || @journal.image_url
   @journal.video_url = params[:video_url] || @journal.video_url
   @journal.health_routines = params[:health_routines] || @journal.health_routines
   @journal.bp_avg = params[:bp_avg] || @journal.bp_avg
   @journal.bp_annotations = params[:bp_annotations] || @journal.bp_annotations
   @journal.image_of_tongue = params[:image_of_tongue] || @journal.image_of_tongue

   if @journal.save
      render "show.json.jb"
   else
    render json: {errors: @recipe.errors.full_messages}, status: 422
   end
end
 def destroy
 journal = Journal.find_by(id: params[:id])
 journal.destroy
 render json: {message: "Journal successfully destroyed!"}
 end

end
