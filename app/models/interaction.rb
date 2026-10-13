class Interaction < ApplicationRecord
  has_many :issues, dependent: :destroy
  accepts_nested_attributes_for :issues, allow_destroy: true

  enum :age, {
    under_20: 0, twenties: 1, thirties: 2, forties: 3, fifties: 4,
    sixties: 5, seventies: 6, eighties: 7, nineties: 8, over_100: 9
  }
  enum :gender, { male: 0, female: 1, nonbinary: 2 }
  enum :estimated_time, {
    under_5_minutes: 0, five_minutes: 1, ten_minutes: 2,
    twenty_minutes: 3, thirty_minutes: 4, over_30_minutes: 5
  }

  validates :age, :gender, :estimated_time, presence: true
  validates :issues, presence: true
end
