# frozen_string_literal: true

class SetDefaultValueToExistingThresholdPerProposal < ActiveRecord::Migration[5.1]
  def change
    components = Decidim::Component.where(manifest_name: "proposals")

    components.each do |component|
      if component.settings.threshold_per_proposal.blank?
        component.settings[:threshold_per_proposal] = "0"
        component.save
      end
    end
  end
end
