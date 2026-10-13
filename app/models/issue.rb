class Issue < ApplicationRecord
  include HasPrimaryNeed

  belongs_to :interaction

  validates :interaction_description, presence: true
end
