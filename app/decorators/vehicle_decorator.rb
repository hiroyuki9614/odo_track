# frozen_string_literal: true

module VehicleDecorator
  WEEK = %w[(日) (月) (火) (水) (木) (金) (土)].freeze
  def week_format
    wday_index = created_at&.wday
    WEEK[wday_index]
  end
end
