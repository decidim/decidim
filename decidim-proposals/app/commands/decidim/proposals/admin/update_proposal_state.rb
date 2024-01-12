# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class UpdateProposalState < Decidim::Commands::UpdateResource
        include TranslatableAttributes

        fetch_form_attributes :title, :default, :answerable, :include_in_stats, :css_class, :notifiable, :gamified, :announcement_title, :component
      end
    end
  end
end
