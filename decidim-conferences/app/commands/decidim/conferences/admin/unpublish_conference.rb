# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command that sets a Conference as unpublished.
      class UnpublishConference < Decidim::Admin::ParticipatorySpace::Unpublish
      end
    end
  end
end
