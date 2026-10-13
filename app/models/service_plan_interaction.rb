class ServicePlanInteraction < ApplicationRecord
  include HasPrimaryNeed

  belongs_to :service_plan
  belongs_to :point_person, class_name: "User", optional: true

  enum :status, { ongoing: 0, completed: 1 }

  validates :date, :action_referrals, presence: true
  validate :point_person_present

  private

  def point_person_present
    return if point_person.present? || point_person_name.present?
    errors.add(:point_person_name, "or point person must be set")
  end
end
