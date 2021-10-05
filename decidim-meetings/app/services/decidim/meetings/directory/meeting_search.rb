# frozen_string_literal: true

module Decidim
  module Meetings
    module Directory
      class MeetingSearch < Decidim::Meetings::MeetingSearch
        text_search_fields :title, :description

        def search_space
          return query if options[:space].blank? || options[:space] == "all"

          query.joins(:component).where(decidim_components: { participatory_space_type: options[:space].collect(&:classify) })
        end

        private

        # Private: Creates an array of category ids.
        # It contains categories' subcategories ids as well.
        def all_category_ids
          cat_ids = fetch_category_ids

          component.flat_map do |comp|
            comp
              .categories
              .where(id: cat_ids)
              .or(comp.categories.where(parent_id: cat_ids))
              .pluck(:id).tap { |ids| ids.prepend(nil) if category_ids.include?("without") }
          end
        end

        # take a param list like ["2", "10", "Decidim__Assembly4", "Decidim__Assembly2"]
        # return a param list like [47, 48, 43, 44, 45, 46, 41, 42, 27, 28, 32, 31, 29, 30, 26, 25]
        def fetch_category_ids
          cat_ids = category_ids.without("without")

          additional_ids = cat_ids.select { |a| a =~ /Decidim__/ }

          additional_ids = parse_category_ids(additional_ids)
          cat_ids.collect(&:to_i).without(0).push(*additional_ids)
        end

        # this function expects an array of the following format : [ "Decidim__Assembly4", "Decidim__Assembly2"]
        # It will transform each parameter into an array of class_name and id [["Decidim::Assembly", "4"], ["Decidim::Assembly", "2"]]
        # After we rebuild the find query and retrun the category_ids for each participatory space
        def parse_category_ids(additional_ids)
          additional_ids = additional_ids.map { |a| a.gsub("__", "::").gsub(/(\d+)/, '.\1').split(".") }
          additional_ids = additional_ids.map { |v| v.first.safe_constantize.send(:find, v.last.to_i).category_ids }
          additional_ids.flatten
        end
      end
    end
  end
end
