# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/participatory_space_members_page_examples"

module Decidim
  module Assemblies
    describe MembersController do
      routes { Decidim::Assemblies::Engine.routes }

      def decidim_assemblies
        Decidim::Assemblies::Engine.routes.url_helpers
      end

      let(:organization) { create(:organization) }

      let!(:participatory_space) do
        create(
          :assembly,
          :published,
          organization:,
          private_space: true
        )
      end

      let(:destination_path) { decidim_assemblies.assembly_path(participatory_space, locale: I18n.locale) }

      let(:slug_param) { "assembly_slug" }
      let(:slug) { participatory_space.slug }

      it_behaves_like "participatory space members page examples"
    end
  end
end
