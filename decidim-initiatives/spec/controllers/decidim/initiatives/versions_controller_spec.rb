# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe VersionsController, versioning: true do
      routes { Decidim::Initiatives::Engine.routes }

      let(:resource) { create(:initiative) }

      it_behaves_like "versions controller"

      context "when the initiative is not publicly readable" do
        let(:resource) { create(:initiative, :created) }

        it_behaves_like "versions controller denying unreadable resources"
      end
    end
  end
end
