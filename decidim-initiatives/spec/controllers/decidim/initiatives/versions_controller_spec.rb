# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe VersionsController, versioning: true, type: :controller do
      routes { Decidim::Initiatives::Engine.routes }

      let(:resource) { create(:initiative) }

      it_behaves_like "versions controller"
    end
  end
end
