# frozen_string_literal: true

namespace :decidim do
  namespace :initiatives do
    namespace :upgrade do
      desc "Fix the broken pages"
      task fix_broken_pages: :environment do
        Decidim::Initiative.find_each do |initiative|
          initiative.components.where(manifest_name: "pages").each do |component|
            next unless Decidim::Pages::Page.where(component:).empty?

            Decidim::Pages::CreatePage.call(component) do
              on(:invalid) { raise "Cannot create page" }
            end
          end
        end
      end
    end
  end
end
