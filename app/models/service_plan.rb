class ServicePlan < ApplicationRecord
  has_many :service_plan_interactions, dependent: :destroy

  validates :client_name, :date_of_contact, presence: true
end
