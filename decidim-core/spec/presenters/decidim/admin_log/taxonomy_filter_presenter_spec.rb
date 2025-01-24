# frozen_string_literal: true

require "spec_helper"

describe Decidim::AdminLog::TaxonomyFilterPresenter, type: :helper do
  context "with user" do
    include_examples "present admin log entry" do
      let(:taxonomy_filter) { create(:taxonomy_filter) }
      let(:admin_log_resource) { taxonomy_filter }
      let(:admin_log_extra_data) do
        {
          extra: {
            participatory_space_manifests: ["participatory_processes"],
            filter_items_count: 99
          }
        }
      end
      let(:action) { "create" }

      describe "#present" do
        subject { presenter.present }

        it "presents the filter items count" do
          expect(subject).to include(admin_log_extra_data[:filter_items_count].to_s)
        end
      end
    end
  end
end
