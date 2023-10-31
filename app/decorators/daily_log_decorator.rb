# frozen_string_literal: true

# Documentation for DailyLogDecorator
module DailyLogDecorator
  WEEK = %w[(日) (月) (火) (水) (木) (金) (土)].freeze

  def week_format
    wday_index = created_at&.wday
    WEEK[wday_index]
  end

  def alcohol_check_text?
    is_alcohol_check ? '実施' : '未実施'
  end

  def studless_tire_text?
    is_studless_tire ? '装着' : '未装着'
  end
end
