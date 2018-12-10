# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Events::BaseEvent do
    let(:user) { build(:user) }

    describe ".types" do
      subject { described_class }

      it "returns an empty array" do
        expect(subject.types).to eq []
      end
    end

    describe "notifiable?" do
      subject do
        described_class.new(
          resource: resource,
          event_name: "some.event",
          user: user,
          extra: {}
        )
      end

      context "when the resource is publicable" do
        let(:resource) { build(:dummy_resource) }

        context "when it is published" do
          before do
            resource.published_at = Time.current
          end

          it { is_expected.to be_notifiable }
        end

        context "when it is not published" do
          before do
            resource.published_at = nil
          end

          it { is_expected.not_to be_notifiable }
        end
      end

      context "when there's a component" do
        let(:resource) { build(:dummy_resource) }

        context "when it is published" do
          before do
            resource.published_at = Time.current
            resource.component.published_at = Time.current
          end

          it { is_expected.to be_notifiable }
        end

        context "when it is not published" do
          before do
            resource.published_at = Time.current
            resource.component.published_at = nil
          end

          it { is_expected.not_to be_notifiable }
        end
      end

      context "when there's a participatory space" do
        let(:resource) { build(:dummy_resource) }

        context "when it is published" do
          before do
            resource.published_at = Time.current
            resource.component.participatory_space.published_at = Time.current
          end

          it { is_expected.to be_notifiable }
        end

        context "when it is not published" do
          before do
            resource.published_at = Time.current
            resource.component.participatory_space.published_at = nil
          end

          it { is_expected.not_to be_notifiable }
        end

        context "and participatory space is participable" do
          before do
            resource.published_at = Time.current
            resource.component.published_at = Time.current
            resource.component.participatory_space.published_at = Time.current
          end

          context "and the user can participate" do
            it { is_expected.to be_notifiable }
          end

          context "and the user can't participate" do
            before do
              allow(resource.component.participatory_space).to receive(:can_participate?).with(user).and_return(false)
            end

            it { is_expected.not_to be_notifiable }
          end
        end
      end

      context "when the resource is a component" do
        let(:resource) { build(:component) }

        it { is_expected.to be_notifiable }

        context "when it is not published" do
          let(:resource) { build(:component, :unpublished) }

          it { is_expected.not_to be_notifiable }
        end
      end

      context "when the resource is a participatory space" do
        let(:resource) { build(:participatory_process) }

        it { is_expected.to be_notifiable }

        context "when it is not published" do
          let(:resource) { build(:participatory_process, :unpublished) }

          it { is_expected.not_to be_notifiable }
        end
      end
    end
  end
end
