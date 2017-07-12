# This migration comes from decidim (originally 20170220110740)
# frozen_string_literal: true

class RemoveStepsShortDescription < ActiveRecord::Migration[5.0]
  def change
    Decidim::ParticipatoryProcessStep.transaction do
      Decidim::ParticipatoryProcessStep.find_each do |step|
        step.update_attributes!(
          description: new_description_for(step)
        )
      end

      remove_column :decidim_participatory_process_steps, :short_description
    end
  end

  def new_description_for(step)
    desc = {}
    step.description.keys.each do |locale|
      desc[locale] = step.short_description[locale] + step.description[locale]
    end
    desc
  end
end
