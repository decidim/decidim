# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    module AdminLog
      describe DocumentPresenter do
        let(:action_log) { double("ActionLog", action: action, resource: resource, extra: extra, version: version) }
        let(:resource) { double("Document", document_versions: [document]) }
        let(:document) { create(:collaborative_text_document, body: "This is and example body") }
        let(:extra) { { "extra" => { "version_number" => "2", "body" => document.body } } }
        let(:version) { double("Version", changeset: {}) }
        let(:presenter) { described_class.new(action_log, nil) }

        describe "#action_string" do
          context "when action is create" do
            let(:action) { "create" }

            it "returns the correct translation key" do
              expect(presenter.send(:action_string)).to eq("decidim.collaborative_texts.admin_log.document.create")
            end
          end

          context "when action is delete" do
            let(:action) { "delete" }

            it "returns the correct translation key" do
              expect(presenter.send(:action_string)).to eq("decidim.collaborative_texts.admin_log.document.delete")
            end
          end
        end

        describe "#changeset" do
          let(:action) { "create" }

          it "returns the expected structured changeset for create action" do
            expected_changeset = [
              {
                attribute_name: :body,
                label: "Body",
                new_value: "This is and example body",
                previous_value: nil,
                type: :string
              },
              {
                attribute_name: :version_number,
                label: "Version number",
                new_value: "1",
                previous_value: nil,
                type: :integer
              }
            ]

            expect(presenter.send(:changeset)).to eq(expected_changeset)
          end

          context "when action is publish" do
            let(:action) { "publish" }

            it "returns the expected structured changeset for publish action" do
              expected_changeset = [
                {
                  attribute_name: :version_number,
                  label: "Version number",
                  new_value: "2",
                  previous_value: nil,
                  type: :integer
                }
              ]

              expect(presenter.send(:changeset)).to eq(expected_changeset)
            end
          end
        end
      end
    end
  end
end
