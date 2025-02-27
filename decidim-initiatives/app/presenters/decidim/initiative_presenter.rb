# frozen_string_literal: true

module Decidim
  #
  # Decorator for initiatives
  #
  class InitiativePresenter < SimpleDelegator
    def author
      @author ||= Decidim::UserPresenter.new(super)
    end
  end
end
