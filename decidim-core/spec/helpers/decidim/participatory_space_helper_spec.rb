# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ParticipatorySpaceHelpers do
    let(:helper) do
      Class.new(ActionView::Base) do
        include ParticipatorySpaceHelpers
        include SanitizeHelper
        include TranslatableAttributes
        include ContextualHelpHelper
        include Decidim::IconHelper

        def compiled_method_container
          self.class
        end
      end.new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, [])
    end

    describe "#participatory_space_floating_help" do
      subject { helper.participatory_space_floating_help }

      before do
        allow(helper).to receive(:help_section).and_return(help_section)
        allow(helper).to receive(:help_id).and_return("participatory_processes")
      end

      context "when help_section is empty" do
        let(:help_section) do
          {}
        end

        it "does not display any help section" do
          expect(subject).to be_blank
        end
      end

      context "when help_section is blank" do
        let(:help_section) do
          {
            en: ""
          }
        end

        it "does not display any help section" do
          expect(subject).to be_blank
        end
      end

      context "when help_section is an empty paragraph" do
        let(:help_section) do
          {
            en: "<p><strong> </strong></p>"
          }
        end

        it "does not display any help section" do
          expect(subject).to be_blank
        end
      end

      context "when help_section is not blank" do
        let(:help_section) do
          {
            en: "<p>participatory processes are ...</p>"
          }
        end

        it "displays a help sections" do
          expect(subject).to include("participatory processes are")
        end
      end
    end
  end
end
