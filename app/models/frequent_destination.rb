class FrequentDestination < ApplicationRecord
  belongs_to :user
  has_many :daily_log

  # validates :destination_name, presence: true
  # validates :destination_note, allow_blank: true
  # validates :user_id, presence: true
end
