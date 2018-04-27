class Coauthorship < ApplicationRecord
  belongs_to :decidim_author
  belongs_to :decidim_user_group
  belongs_to :coauthorable
end
