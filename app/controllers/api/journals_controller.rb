class Api::JournalsController < Api::BaseController
  def index
    limit = params[:limit] || 9
    offset = params[:offset] || 0
    @template = current_user.journal_template
    @journals = Journal.where(journal_template: @template).where.not(metrics: nil).limit(limit).offset(offset)
    @total_records = Journal.where(journal_template: @template).where.not(metrics: nil).count
    @enriched_metrics = Journals::EnrichMetrics.new(@journals, @template).with_units
  end

  def new
    @journal_template = JournalTemplate.find_by(user: current_user)
    @health_metrics = HealthMetric.where(journal_template: @journal_template)
    render json: @health_metrics
  end

  def show
    journal_id = params[:id]
    @journal = Journal.find(journal_id)
    @journals = Journal.where(id: journal_id)
    @template = current_user.journal_template
    @enriched_metrics = Journals::EnrichMetrics.new(@journals, @template).with_units
    if @journals.first.user == current_user
      render "show"
    else
      render json: { errors: "Unauthorized" }, status: 422
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
      render json: { errors: @journal.errors.full_messages }, status: 422
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
        render "show"
      else
        render json: { errors: @journal.errors.full_messages }, status: 422
      end
    else
      render json: { errors: "Unauthorized" }, status: 422
    end
  end

  def destroy
    journal = current_user.journals.find_by(id: params[:id])
    if journal
      journal.destroy
      render json: { message: "Journal successfully destroyed!" }
    else
      render json: { message: "Journal does not exist" }, status: 422
    end
  end
end
