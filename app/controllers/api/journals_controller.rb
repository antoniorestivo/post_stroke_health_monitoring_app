class Api::JournalsController < Api::BaseController
  before_action :set_journal_template, only: [:index, :new]
  before_action :set_journal_for_current_user, only: [:show, :update, :destroy]

  def index
    limit = (params[:limit] || 9).to_i
    offset = (params[:offset] || 0).to_i
    limit = 100 if limit > 100
    offset = 0 if offset.negative?

    @journals = current_user.journals
                            .where(journal_template: @journal_template)
                            .where.not(metrics: nil)
                            .limit(limit)
                            .offset(offset)
    @total_records = current_user.journals
                                 .where(journal_template: @journal_template)
                                 .where.not(metrics: nil)
                                 .count
    @enriched_metrics = Journals::EnrichMetrics.new(@journals, @journal_template).with_units
  end

  def new
    @health_metrics = HealthMetric.where(journal_template: @journal_template)
    render json: @health_metrics
  end

  def show
    collection = current_user.journals.where(id: params[:id])
    @journal = collection&.first
    @template = current_user.journal_template
    @enriched_metrics = Journals::EnrichMetrics.new(collection, @template).with_units
    render "show"
  end

  def create
    template = JournalTemplate.find_by(user: current_user)
    @journal = current_user.journals.new(journal_params.merge(journal_template: template))

    if @journal.save
      @journals = Journal.where(id: @journal.id)
      @template = current_user.journal_template
      @enriched_metrics = Journals::EnrichMetrics.new(@journals, @template).with_units
      render "show", status: :created
    else
      render json: { errors: @journal.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @journal.update(journal_params)
      @journals = Journal.where(id: @journal.id)
      @template = current_user.journal_template
      @enriched_metrics = Journals::EnrichMetrics.new(@journals, @template).with_units
      render "show"
    else
      render json: { errors: @journal.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @journal.destroy
    render json: { message: "Journal successfully destroyed!" }
  end

  private

  def set_journal_template
    @journal_template = current_user.journal_template
  end

  def set_journal_for_current_user
    @journal = current_user.journals.find_by(id: params[:id])
    return if @journal

    render json: { errors: "Not found" }, status: :not_found
  end

  def journal_params
    params.require(:journal).permit(
      :description,
      :image_url,
      :video_url,
      :health_routines,
      metrics: {}
    )
  end
end