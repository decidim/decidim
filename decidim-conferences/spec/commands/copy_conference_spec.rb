# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::CopyConference do
    subject { described_class.new(form, conference) }

    let(:organization) { create(:organization) }
    let(:errors) { double.as_null_object }
    let!(:conference) { create(:conference, organization:, taxonomies: [taxonomy]) }
    let(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
    let!(:component) { create(:component, manifest_name: :dummy, participatory_space: conference) }
    let(:form) do
      instance_double(
        Admin::ConferenceCopyForm,
        invalid?: invalid,
        title: { en: "title" },
        slug: "copied-slug",
        copy_components?: copy_components
      )
    end

    let(:invalid) { false }
    let(:copy_components) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "duplicates a conference" do
        expect { subject.call }.to change(Decidim::Conference, :count).by(1)

        old_conference = Decidim::Conference.first
        new_conference = Decidim::Conference.last

        expect(new_conference.slug).to eq("copied-slug")
        expect(new_conference.title["en"]).to eq("title")
        expect(new_conference).not_to be_published
        expect(new_conference.organization).to eq(old_conference.organization)
        expect(new_conference.slogan).to eq(old_conference.slogan)
        expect(new_conference.description).to eq(old_conference.description)
        expect(new_conference.short_description).to eq(old_conference.short_description)
        expect(new_conference.promoted).to eq(old_conference.promoted)
        expect(new_conference.objectives).to eq(old_conference.objectives)
        expect(new_conference.start_date).to eq(old_conference.start_date)
        expect(new_conference.end_date).to eq(old_conference.end_date)
        expect(new_conference.taxonomies).to eq(old_conference.taxonomies)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end
    end

    context "when copy_components exists" do
      let(:copy_components) { true }

      it "duplicates a conference and the components" do
        dummy_hook = proc {}
        component.manifest.on :copy, &dummy_hook
        expect(dummy_hook).to receive(:call).with({ new_component: an_instance_of(Decidim::Component), old_component: component })

        expect { subject.call }.to change(Decidim::Component, :count).by(1)

        last_conference = Decidim::Conference.last
        last_component = Decidim::Component.all.reorder(:id).last

        expect(last_component.participatory_space).to eq(last_conference)
        expect(last_component.name).to eq(component.name)
        expect(last_component.settings.attributes).to eq(component.settings.attributes)
        expect(last_component.step_settings.keys).to eq(component.step_settings.keys)
        expect(last_component.step_settings.values).to eq(component.step_settings.values)
      end
    end
  end
end
