# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/participatory_space_members_page_examples"

module Decidim
  module ParticipatoryProcesses
    describe ParticipatorySpacePrivateUsersController do
      routes { Decidim::ParticipatoryProcesses::Engine.routes }

      let(:organization) { create(:organization) }
      let(:destination_path) { decidim_participatory_processes.participatory_process_path(privatable_to, locale: I18n.locale) }
      let(:slug_param) { "participatory_process_slug" }
      let(:slug) { privatable_to.slug }

      let!(:privatable_to) do
        create(
          :participatory_process,
          :published,
          organization:,
          private_space: true
        )
      end

      def decidim_participatory_processes
        Decidim::ParticipatoryProcesses::Engine.routes.url_helpers
      end

      it_behaves_like "participatory space members page examples"
    end
  end
end
