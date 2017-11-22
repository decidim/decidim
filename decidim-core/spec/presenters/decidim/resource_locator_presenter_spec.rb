# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ResourceLocatorPresenter, type: :helper do
    let(:organization) { create(:organization, host: "1.lvh.me") }

    let(:participatory_process) do
      create(:participatory_process, slug: "my-process", organization: organization)
    end

    let(:feature) do
      create(:feature, id: 1, participatory_space: participatory_process)
    end

    let(:resource) do
      create(:dummy_resource, id: 1, feature: feature)
    end

    context "with a feature resource" do
      describe "#url" do
        subject { described_class.new(resource).url }

        it { is_expected.to eq("http://1.lvh.me/processes/my-process/f/1/dummy_resources/1") }

        context "when specific port configured" do
          before do
            allow(ActionMailer::Base)
              .to receive(:default_url_options)
              .and_return(port: 3000)
          end

          it { is_expected.to eq("http://1.lvh.me:3000/processes/my-process/f/1/dummy_resources/1") }
        end
      end

      describe "#path" do
        subject { described_class.new(resource).path }

        it { is_expected.to eq("/processes/my-process/f/1/dummy_resources/1") }
      end
    end

    context "with a participatory_space" do
      describe "#url" do
        subject { described_class.new(participatory_process).url }

        it { is_expected.to start_with("http://1.lvh.me/processes/my-process") }
      end

      describe "#path" do
        subject { described_class.new(participatory_process).path }

        it { is_expected.to start_with("/processes/my-process") }
      end
    end
  end
end
