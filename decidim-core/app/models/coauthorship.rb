class Coauthorship < ApplicationRecord
  belongs_to :author, foreign_key: "decidim_author_id", class_name: "Decidim::User"
  belongs_to :user_group, foreign_key: "decidim_user_group_id", class_name: "Decidim::UserGroup", optional: true
  belongs_to :coauthorable, polymorphic: true
end
