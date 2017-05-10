# frozen_string_literal: true
require "decidim/core/test/factories"

FactoryGirl.define do
  factory :surveys_feature, parent: :feature do
    name { Decidim::Features::Namer.new(participatory_process.organization.available_locales, :surveys).i18n_name }
    manifest_name :surveys
    participatory_process { create(:participatory_process, :with_steps) }
  end

  # Add engine factories here
end
