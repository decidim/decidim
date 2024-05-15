# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class UpdateProposalState < Decidim::Commands::UpdateResource
        include TranslatableAttributes

        fetch_form_attributes :title, :text_color, :bg_color, :announcement_title, :component
      end
    end
  end
end
