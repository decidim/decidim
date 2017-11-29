# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Traceable, versioning: true do
    subject { resource }

    let(:resource) do
      create(:dummy_resource)
    end

    it { is_expected.to be_versioned }

    context "with versions" do
      before do
        Decidim.traceability.update!(subject, "test suite", title: "My new title")
      end

      describe "last_whodunnit" do
        it "returns the author of the last version" do
          Decidim.traceability.update!(subject, "another test suite", title: "My new title 2")
          expect(subject.last_whodunnit).to eq "another test suite"
        end
      end

      describe "last_editor" do
        context "when last editor is a user" do
          let(:user) { create :user }

          it "returns the user" do
            Decidim.traceability.update!(subject, user, title: "My new title 3")

            expect(subject.last_editor).to eq user
          end
        end

        context "when last editor is a string" do
          it "returns the string" do
            Decidim.traceability.update!(subject, "my test suite", title: "My new title 4")

            expect(subject.last_editor).to eq "my test suite"
          end
        end
      end
    end
  end
end
