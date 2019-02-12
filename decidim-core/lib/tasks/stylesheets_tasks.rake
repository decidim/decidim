# frozen_string_literal: true

namespace :assets do
  def organizations_stylesheet
    Decidim::Organization.find_each do |organization|
      Decidim::Stylesheets.store(organization)
    end
  end
end

Rake::Task["assets:precompile"].enhance do
  organizations_stylesheet
end
