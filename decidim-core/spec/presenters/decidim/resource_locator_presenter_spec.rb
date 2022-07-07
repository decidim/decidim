# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ResourceLocatorPresenter, type: :helper do
    let(:organization) { create(:organization, host: "1.lvh.me") }

    let(:participatory_process) do
      create(:participatory_process, slug: "my-process", organization: organization)
    end

    let(:component) do
      create(:component, id: 1, participatory_space: participatory_process)
    end

    let(:resource) do
      create(:dummy_resource, id: 1, component: component)
    end

    context "with a component resource" do
      describe "#url" do
        subject { described_class.new(resource).url }

        it { is_expected.to eq("http://1.lvh.me:#{Capybara.server_port}/processes/my-process/f/1/dummy_resources/1") }

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

      describe "#show" do
        subject { described_class.new(participatory_process).show }

        it { is_expected.to start_with("/admin/participatory_processes/my-process") }
      end

      describe "#edit" do
        subject { described_class.new(participatory_process).edit }

        it { is_expected.to start_with("/admin/participatory_processes/my-process/edit") }
      end
    end

    context "with a polymorphic resource" do
      let(:nested_resource) do
        create(:nested_dummy_resource, id: 1, dummy_resource: resource)
      end

      describe "#url" do
        subject { described_class.new([resource, nested_resource]).url }

        it { is_expected.to eq("http://1.lvh.me:#{Capybara.server_port}/processes/my-process/f/1/dummy_resources/1/nested_dummy_resources/1") }

        context "when specific port configured" do
          before do
            allow(ActionMailer::Base)
              .to receive(:default_url_options)
              .and_return(port: 3000)
          end

          it { is_expected.to eq("http://1.lvh.me:3000/processes/my-process/f/1/dummy_resources/1/nested_dummy_resources/1") }
        end
      end

      describe "#path" do
        subject { described_class.new([resource, nested_resource]).path }

        it { is_expected.to eq("/processes/my-process/f/1/dummy_resources/1/nested_dummy_resources/1") }
      end

      describe "#index" do
        subject { described_class.new([resource, nested_resource]).index }

        it { is_expected.to eq("/processes/my-process/f/1/dummy_resources/1/nested_dummy_resources") }
      end

      describe "#admin_index" do
        subject { described_class.new([resource, nested_resource]).admin_index }

        it { is_expected.to start_with("/admin/participatory_processes/my-process/components/1/manage/dummy_resources/1/nested_dummy_resources") }
      end

      describe "#show" do
        subject { described_class.new([resource, nested_resource]).show }

        it { is_expected.to start_with("/admin/participatory_processes/my-process/components/1/manage/dummy_resources/1/nested_dummy_resources/1") }
      end

      describe "#edit" do
        subject { described_class.new([resource, nested_resource]).edit }

        it { is_expected.to start_with("/admin/participatory_processes/my-process/components/1/manage/dummy_resources/1/nested_dummy_resources/1/edit") }
      end
    end

    context "with a participatory_space" do
      describe "#url" do
        subject { described_class.new(participatory_process).url }

        it { is_expected.to start_with("http://1.lvh.me:#{Capybara.server_port}/processes/my-process") }
      end

      describe "#path" do
        subject { described_class.new(participatory_process).path }

        it { is_expected.to start_with("/processes/my-process") }
      end
    end
  end
end
