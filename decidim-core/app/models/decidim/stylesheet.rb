# frozen_string_literal: true

module Decidim
  class Stylesheet < ApplicationRecord
    after_commit :compile_assets
    belongs_to :organization, foreign_key: :decidim_organization_id,
                              class_name: "Decidim::Organization"

    private

    def compile_assets
      StylesheetCompileJob.perform_later(id)
    end
  end
end
