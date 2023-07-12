# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Accountability
    describe VersionsController, type: :controller, versioning: true do
      routes { Decidim::Accountability::Engine.routes }

      let(:resource) { create(:result) }

      it_behaves_like "versions controller"
    end
  end
end
