class Api::JournalsController < ApplicationController
  before_action :authenticate_user
  def index
    @template = current_user.journal_template
    @journals = Array.wrap(@template&.journals)

    render "index.json.jb"
  end

  def new
    @journal_template = JournalTemplate.find_by(user: current_user)
    @health_metrics = HealthMetric.where(journal_template: @journal_template)
    render json: @health_metrics
  end

  def show
    journal_id = params[:id]
    @journal = Journal.find(journal_id)
    if @journal.user == current_user
      render "show.json.jb"
    else
      render json: {errors: "Unauthorized"}, status: 422
    end
  end

  def create
    Rails.logger.warn("Params: #{params.inspect}")
    template = JournalTemplate.find_by(user: current_user)
    @journal = Journal.new(
      journal_template: template,
      description: params[:description],
      image_url: params[:image_url],
      video_url: params[:video_url],
      health_routines: params[:health_routines],
      metrics: params[:metrics]
    )
    if @journal.save
      redirect_to action: :index
    else
      render json: {errors: @journal.errors.full_messages}, status: 422
    end
  end
  def update
    journal_id = params[:id]
    @journal = current_user.journals.find_by(id: journal_id)

    if @journal
      @journal.description = params[:description] || @journal.description
      @journal.image_url = params[:image_url] || @journal.image_url
      @journal.video_url = params[:video_url] || @journal.video_url
      @journal.health_routines = params[:health_routines] || @journal.health_routines
      @journal.metrics = params[:metrics] || @journal.metrics
      if @journal.save
        render "show.json.jb"
      else
        render json: {errors: @recipe.errors.full_messages}, status: 422
      end
    else
      render json: {errors: "Unauthorized"}, status: 422
    end 
  end
  
  def destroy
    journal = current_user.journals.find_by(id: params[:id])
    if journal
      journal.destroy
      render json: {message: "Journal successfully destroyed!"}
    else
      render json: {message: "Journal does not exist"}, status: 422
    end

  end

end
