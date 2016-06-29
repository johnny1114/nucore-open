module SangerSequencing

  class BatchForm

    include ActiveModel::Validations

    attr_reader :batch

    delegate :submission_ids, to: :batch

    validates :submission_ids, presence: true
    validate :samples_must_match_submissions
    validate :submission_part_of_other_batch

    def initialize(batch = SangerSequencing::Batch.new)
      @batch = batch
    end

    def assign_attributes(params = {})
      batch.submission_ids = params[:submission_ids].to_s.split(",")
      batch.well_plates_raw = params[:well_plate_data].to_h.values
      batch.created_by = params[:created_by]
    end

    def update_attributes(params = {})
      assign_attributes(params)
      save
    end

    def save
      batch.save if valid?
    end

    private

    def submission_part_of_other_batch
      changed = Submission.where(id: batch.submission_ids).where.not(batch: nil).pluck(:id)
      if changed.any?
        errors.add(:submission_ids, :submission_part_of_other_batch, id: changed.join(", "))
      end
    end

    def samples_must_match_submissions
      unless submitted_sample_ids.to_set == sample_ids_from_submissions.to_set
        errors.add(:submitted_sample_ids, :must_match_submissions)
      end
    end

    def sample_ids_from_submissions
      batch.submissions.flat_map(&:samples).map { |s| s.id.to_s }
    end

    # The list of all the samples submitted into the form
    def submitted_sample_ids
      batch.well_plates_raw.flat_map(&:values).map(&:to_s).select { |id| id =~ /\A\d+\z/ }
    end

  end

end