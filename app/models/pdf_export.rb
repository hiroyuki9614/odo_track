# frozen_string_literal: true

class PdfExport < ApplicationRecord
  STATUSES = %w[processing completed failed].freeze

  belongs_to :created_by, class_name: 'User', optional: true

  validates :target_month, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :pdf_count, numericality: { greater_than_or_equal_to: 0 }

  before_validation :normalize_target_month

  scope :recent_first, -> { order(created_at: :desc) }

  def directory
    Rails.root.join('downloads', 'pdf_exports', id.to_s)
  end

  def archive_path
    return if zip_filename.blank?

    directory.join(zip_filename)
  end

  private

  def normalize_target_month
    self.target_month = target_month.beginning_of_month if target_month.present?
  end
end
