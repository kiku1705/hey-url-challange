# frozen_string_literal: true

class Click < ApplicationRecord
  belongs_to :url, counter_cache: true

  scope :current_month_clicks, -> (url_id) { select("extract(day from created_at)::int as day, count(*) as clicks").order("extract(day from created_at)::int ASC").where(url_id:url_id, created_at: Time.zone.now.beginning_of_month..Time.zone.now.end_of_month).group("extract(day from created_at)::int") }

  scope :browser_stats, -> (url_id) { select("browser, count(*) as clicks").order("browser ASC").where(url_id:url_id).group("browser") }

  scope :platform_stats, -> (url_id) { select("platform, count(*) as clicks").order("platform ASC").where(url_id:url_id).group("platform") }
end
