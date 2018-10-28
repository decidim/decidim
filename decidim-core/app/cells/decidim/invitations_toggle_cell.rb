# frozen_string_literal: true

module Decidim
  # This cell only holds two partials needed to use the ToggleCell in the
  # invitations page.
  class InvitationsToggleCell < Decidim::ViewModel
    include LayoutHelper

    def show
      nil
    end

    def label
      render
    end

    def content
      render
    end

    private

    def form
      options[:form]
    end
  end
end
