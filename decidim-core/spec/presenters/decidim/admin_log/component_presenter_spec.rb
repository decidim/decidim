# frozen_string_literal: true

require "spec_helper"

describe Decidim::AdminLog::ComponentPresenter, type: :helper do
  include_examples "present admin log entry" do
    let(:admin_log_resource) { create(:component, organization:) }
    let(:action) { "unpublish" }
  end

  include_examples "present admin log entry", versioning: true do
    let(:admin_log_resource) { create(:component, organization:) }
    let(:root_taxonomy) { create(:taxonomy, organization:, name: { en: "A taxonomy" }) }
    let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
    let(:action) { "update_filters" }

    describe "#present", versioning: true do
      subject { presenter.present }

      before do
        admin_log_resource.update!(settings: { taxonomy_filters: [taxonomy_filter.id, taxonomy_filter.id + 1000] })
        allow(action_log).to receive(:version).and_return(admin_log_resource.versions.last)
      end

      it "returns a diff" do
        expect(subject).to include("class=\"logs__log__diff\"")
        expect(subject).to include(taxonomy_filter.translated_internal_name)
        expect(subject).to include((taxonomy_filter.id + 1000).to_s)
      end
    end
  end
end
