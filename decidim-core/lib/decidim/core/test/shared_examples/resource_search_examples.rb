# frozen_string_literal: true

require "spec_helper"

shared_examples_for "a resource search" do |factory_name|
  context "when no component is passed" do
    let(:params) { default_params.merge(component: nil) }

    it "raises an error" do
      expect { subject }.to raise_error(StandardError, "Missing component")
    end
  end

  describe "component_id" do
    it "only returns resources from the given component" do
      external_resource = create(factory_name)

      expect(subject).not_to include(external_resource)
    end
  end
end

shared_examples_for "a resource search with scopes" do |factory_name|
  let(:factory_params) do
    resource_params
  rescue StandardError
    {}
  end

  describe "scope_id filter" do
    let(:params) { default_params.merge(scope_id: scope_ids) }

    let(:scope1) { create :scope, organization: component.organization }
    let(:scope2) { create :scope, organization: component.organization }
    let(:subscope1) { create :scope, organization: component.organization, parent: scope1 }

    let!(:resource) { create(factory_name, { component: component, scope: scope1 }.merge(factory_params)) }
    let!(:resource2) { create(factory_name, { component: component, scope: scope2 }.merge(factory_params)) }
    let!(:resource3) { create(factory_name, { component: component, scope: subscope1 }.merge(factory_params)) }

    context "when a parent scope id is being sent" do
      let(:scope_ids) { [scope1.id] }

      it "filters resources by scope" do
        expect(subject).to match_array [resource, resource3]
      end
    end

    context "when a subscope id is being sent" do
      let(:scope_ids) { [subscope1.id] }

      it "filters resources by scope" do
        expect(subject).to eq [resource3]
      end
    end

    context "when multiple ids are sent" do
      let(:scope_ids) { [scope2.id, scope1.id] }

      it "filters resources by scope" do
        expect(subject).to match_array [resource, resource2, resource3]
      end
    end

    context "when `global` is being sent" do
      let!(:resource_without_scope) { create(factory_name, { component: component, scope: nil }.merge(factory_params)) }
      let(:scope_ids) { ["global"] }

      it "returns resources without a scope" do
        expect(subject).to match_array [resource_without_scope]
      end
    end

    context "when `global` and some ids is being sent" do
      let!(:resource_without_scope) { create(factory_name, { component: component, scope: nil }.merge(factory_params)) }
      let(:scope_ids) { ["global", scope2.id, scope1.id] }

      it "returns resources without a scope and with selected scopes" do
        expect(subject).to match_array [resource_without_scope, resource, resource2, resource3]
      end
    end
  end
end

shared_examples_for "a resource search with categories" do |factory_name|
  let(:participatory_process) { component.participatory_space }
  let(:params) { default_params.merge(category_id: category_ids) }
  let(:factory_params) do
    resource_params
  rescue StandardError
    {}
  end

  describe "results" do
    let(:category1) { create :category, participatory_space: participatory_process }
    let(:category2) { create :category, participatory_space: participatory_process }
    let(:child_category) { create :category, participatory_space: participatory_process, parent: category2 }
    let!(:resource) { create(factory_name, { component: component }.merge(factory_params)) }
    let!(:resource2) { create(factory_name, { component: component, category: category1 }.merge(factory_params)) }
    let!(:resource3) { create(factory_name, { component: component, category: category2 }.merge(factory_params)) }
    let!(:resource4) { create(factory_name, { component: component, category: child_category }.merge(factory_params)) }

    context "when no category filter is present" do
      let(:category_ids) { nil }

      it "includes all resources" do
        expect(subject).to match_array [resource, resource2, resource3, resource4]
      end
    end

    context "when a category is selected" do
      let(:category_ids) { [category2.id] }

      it "includes only resources for that category and its children" do
        expect(subject).to match_array [resource3, resource4]
      end
    end

    context "when a subcategory is selected" do
      let(:category_ids) { [child_category.id] }

      it "includes only resources for that category" do
        expect(subject).to eq [resource4]
      end
    end

    context "when `without` is being sent" do
      let(:category_ids) { ["without"] }

      it "returns resources without a category" do
        expect(subject).to eq [resource]
      end
    end

    context "when `without` and some category id is being sent" do
      let(:category_ids) { ["without", category1.id] }

      it "returns resources without a category and with the selected category" do
        expect(subject).to match_array [resource, resource2]
      end
    end
  end
end

shared_examples_for "a resource search with origin" do |factory_name|
  let(:factory_params) do
    resource_params
  rescue StandardError
    {}
  end
  let(:params) { default_params.merge(origin: origins) }

  describe "results" do
    let!(:official_resource) { create(factory_name, :official, { component: component }.merge(factory_params)) }
    let!(:user_group_resource) { create(factory_name, :user_group_author, { component: component }.merge(factory_params)) }
    let!(:citizen_resource) { create(factory_name, :citizen_author, { component: component }.merge(factory_params)) }

    if FactoryBot.factory_by_name(factory_name).defined_traits.map(&:name).include?(:meeting_resource)
      let!(:meeting_resource) { create(factory_name, :official_meeting, { component: component }.merge(factory_params)) }
    end

    context "when filtering official resources" do
      let(:origins) { %w(official) }

      it "returns only official resources" do
        expect(subject.size).to eq(1)
        expect(subject).to include(official_resource)
      end
    end

    context "when filtering citizen resources" do
      let(:origins) { %w(citizens) }

      it "returns only citizen resources" do
        expect(subject.size).to eq(1)
        expect(subject).to include(citizen_resource)
      end
    end

    context "when filtering user groups resources" do
      let(:origins) { %w(user_group) }

      it "returns only user groups resources" do
        expect(subject.size).to eq(1)
        expect(subject).to include(user_group_resource)
      end
    end

    if respond_to?(:meeting_resource)
      context "when filtering meetings resources" do
        let(:origins) { %w(meeting) }

        it "returns only meeting resources" do
          expect(subject.size).to eq(1)
          expect(subject).to include(meeting_resource)
        end
      end
    end
  end
end
