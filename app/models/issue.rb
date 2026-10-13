class Issue < ApplicationRecord
  belongs_to :interaction

  enum :primary_need, { housing: 0, food: 1, insurance: 2, mental_health: 3, medical: 4, other: 5 }

  validates :primary_need, :interaction_description, presence: true
  validates :primary_need_other_detail, presence: true, if: :other?
end
