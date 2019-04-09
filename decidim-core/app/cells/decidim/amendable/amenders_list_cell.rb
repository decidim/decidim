# frozen_string_literal: true

module Decidim::Amendable
  # This cell renders a list with amenders of the given amendable resource.
  class AmendersListCell < Decidim::ViewModel
    include Decidim::ApplicationHelper

    private

    def show
      return unless amenders.count.positive?

      render :show
    end

    def amendable
      model
    end

    # Returns a UserPresenter array
    def amenders
      @amenders ||= amendable.amendments.map { |amendment| present(amendment.amender) }.uniq
    end

    def options
      { extra_classes: ["author-data--small"] }
    end
  end
end
