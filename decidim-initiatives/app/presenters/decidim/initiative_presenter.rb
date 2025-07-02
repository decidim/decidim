# frozen_string_literal: true

module Decidim
  #
  # Decorator for initiatives
  #
  class InitiativePresenter < Decidim::ResourcePresenter
    def author
      @author ||= super.presenter
    end

    def initiative
      __getobj__
    end

    def title(links: nil, html_escape: false, all_locales: false)
      return unless initiative

      raise "Links have been set" unless links.nil?

      super(initiative.title, nil, html_escape, all_locales)
    end
  end
end
