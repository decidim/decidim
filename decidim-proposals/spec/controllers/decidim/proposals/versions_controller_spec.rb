# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe VersionsController, versioning: true, type: :controller do
      routes { Decidim::Proposals::Engine.routes }

      let(:resource) { create(:proposal) }

      it_behaves_like "versions controller"
    end
  end
end
