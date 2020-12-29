# frozen_string_literal: true

module Decidim::Verifications
  class Conflict < ApplicationRecord
    belongs_to :current_user, class_name: "User"
    belongs_to :managed_user, class_name: "User"
  end
end
