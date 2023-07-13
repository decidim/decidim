# frozen_string_literal: true

module Decidim::Amendable
  # This cell renders the list of amendments of a resource.
  class AmendmentsCell < Decidim::ViewModel
    include Decidim::ApplicationHelper
    include Decidim::CardHelper
    include Decidim::IconHelper

    delegate :amendable?, :visible_emendations_for, to: :model

    def show
      return unless amendable?
      return unless emendations.any?

      render
    end

    private

    def emendations
      @emendations ||= visible_emendations_for(current_user)
    end
  end
end
