# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/participatory_space_members_page_examples"

module Decidim
  module ParticipatoryProcesses
    describe ParticipatorySpacePrivateUsersController do
      routes { Decidim::ParticipatoryProcesses::Engine.routes }

      let(:organization) { create(:organization) }

      let!(:privatable_to) do
        create(
          :participatory_process,
          :published,
          organization:,
          private_space: true
        )
      end

      let(:slug_param) { "participatory_process_slug" }
      let(:slug) { privatable_to.slug }

      it_behaves_like "participatory space members page examples"
    end
  end
end
