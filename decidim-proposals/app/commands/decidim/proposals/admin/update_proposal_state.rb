# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class UpdateProposalState < Decidim::Commands::UpdateResource
        include TranslatableAttributes

        fetch_form_attributes :title, :css_class, :announcement_title, :component
      end
    end
  end
end
