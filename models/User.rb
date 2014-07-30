require "active_record"

class User < ActiveRecord::Base
  has_many :fishes

  validates :username, presence: { message: "is required" }
  validates :password, presence: { message: "is required" }
  validates :password, :length => { minimum: 4,
                                    message: "must be at least 4 characters"}
  validates :username, uniqueness: true
end