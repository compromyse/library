class User < ApplicationRecord
  has_secure_password

  enum :status, { pending: 0, approved: 1, denied: 2 }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
