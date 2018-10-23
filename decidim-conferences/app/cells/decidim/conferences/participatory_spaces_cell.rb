# frozen_string_literal: true

module Decidim
  module Conferences
    # This cell renders the participatory spaces card for an instance of a Participatory Space
    class ParticipatorySpacesCell < Decidim::ViewModel
      include Decidim::ApplicationHelper
      include Decidim::CardHelper

      def show
        render
      end

      private

      def title
        model.first.class.name.demodulize.tableize
      end
    end
  end
end
