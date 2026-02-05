class Api::JournalsController < Api::BaseController
  before_action :set_journal_template
  before_action :set_journal_for_current_user, only: [:show, :update, :destroy]

  def index
    limit = (params[:limit] || 9).to_i
    limit = 100 if limit > 100
    limit = 9 if limit <= 0

    offset = (params[:offset] || 0).to_i
    offset = 0 if offset.negative?

    scope = current_user.journals
                        .where(journal_template: @template)
                        .where.not(metrics: nil)

    @journals = scope.limit(limit).offset(offset)
    @total_records = scope.count

    @enriched_metrics = Journals::EnrichMetrics.new(@journals, @template).with_units
  end

  def new
    @health_metrics = HealthMetric.where(journal_template: @template)
    render json: @health_metrics
  end

  def show
    @enriched_metrics = Journals::EnrichMetrics.new([@journal], @template).with_units
    render "show"
  end

  def create
    @journal = current_user.journals.new(journal_params.merge(journal_template: @template))

    @journal.save!
    @enriched_metrics = Journals::EnrichMetrics.new([@journal], @template).with_units

    render "show", status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
  end

  def update
    @journal.update!(journal_params)
    @enriched_metrics = Journals::EnrichMetrics.new([@journal], @template).with_units

    render "show"
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
  end

  def destroy
    @journal.destroy
    render json: { message: "Journal successfully destroyed!" }
  end

  private

  def set_journal_template
    @template = current_user.journal_template!
  end

  def set_journal_for_current_user
    @journal = current_user.journals.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: "Not found" }, status: :not_found
    return
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