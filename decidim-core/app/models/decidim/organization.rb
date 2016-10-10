# frozen_string_literal: true
module Decidim
  # Organizations are one of the main models of Decidim. In a single Decidim
  # installation we can find many organizations and each of them can start
  # their own participatory processes.
  class Organization < ApplicationRecord
    has_many :participatory_processes, foreign_key: "decidim_organization_id", class_name: Decidim::ParticipatoryProcess
    validates :name, :host, uniqueness: true
  end
end
