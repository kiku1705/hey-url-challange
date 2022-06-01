# frozen_string_literal: true

class Url < ApplicationRecord
  validates :short_url, :original_url, presence: true
  scope :latest, -> (limit) Url.order('created_at DESC').limit(limit)
end
