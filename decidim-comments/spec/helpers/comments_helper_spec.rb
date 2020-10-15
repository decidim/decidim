# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CommentsHelper do
      let(:dummy_resource) { create(:dummy_resource) }
      let(:machine_translations_toggled?) { false }

      before do
        allow(helper)
          .to receive(:machine_translations_toggled?)
          .and_return(machine_translations_toggled?)
      end

      describe "comments_for" do
        it "renders the react component `Comments` with the correct data" do
          allow(helper)
            .to receive(:machine_translations_toggled?)
            .and_return(false)

          expect(helper)
            .to receive(:react_comments_component)
            .with(
              "comments-for-DummyResource-#{dummy_resource.id}",
              commentableType: "Decidim::DummyResources::DummyResource",
              commentableId: dummy_resource.id.to_s,
              locale: I18n.locale,
              toggleTranslations: machine_translations_toggled?,
              commentsMaxLength: 1000
            ).and_call_original

          helper.comments_for(dummy_resource)
        end
      end

      describe "#comments_max_length" do
        context "when no default comments length specified" do
          let(:dummy_resource) { create(:dummy_resource) }

          it "returns 1000" do
            expect(helper.comments_max_length(dummy_resource)).to eq(1000)
          end
        end

        context "when organization has a default comments length params" do
          let!(:body) { ::Faker::Lorem.sentence(1600) }
          let(:organization) { create(:organization, comments_max_length: 1500) }
          let(:component) { create(:component, organization: organization, manifest_name: "dummy") }
          let!(:dummy_resource) { create(:dummy_resource, component: component) }

          it "returns 1000" do
            expect(helper.comments_max_length(dummy_resource)).to eq(1500)
          end

          context "when component has a default comments length params" do
            it "is invalid" do
              component.update!(settings: { comments_max_length: 2000 })
              expect(helper.comments_max_length(dummy_resource)).to eq(2000)
            end
          end
        end
      end
    end
  end
end
