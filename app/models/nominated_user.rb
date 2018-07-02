class NominatedUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_secure_token :registration_token
  validates :email, uniqueness: true
end