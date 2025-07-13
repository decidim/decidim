# frozen_string_literal: true

require "spec_helper"

describe Decidim::AdminLog::TaxonomyPresenter, type: :helper do
  context "with user" do
    include_examples "present admin log entry" do
      let(:taxonomy) { create(:taxonomy) }
      let(:admin_log_resource) { taxonomy }
      let(:admin_log_extra_data) do
        {
          extra: {
            parent_name: { en: "Parent name" }
          }
        }
      end
      let(:action) { "create" }

      describe "#present" do
        subject { presenter.present }

        it "presents the taxonomy" do
          expect(subject).to include("Parent name")
        end
      end
    end
  end
end
