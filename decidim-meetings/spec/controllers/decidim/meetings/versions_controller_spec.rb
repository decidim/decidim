# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe VersionsController, versioning: true, type: :controller do
      routes { Decidim::Meetings::Engine.routes }

      let(:resource) { create(:meeting) }

      it_behaves_like "versions controller"
    end
  end
end
