# frozen_string_literal: true

module Decidim
  module Admin
    class SelectiveNewsletterParticipatorySpaceForm < Form
      mimic :participatory_space

      attribute :id, Integer

      def map_model(participatory_space)
        self.id = participatory_space.id
      end
    end
  end
end
