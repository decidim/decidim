# frozen_string_literal: true

require "spec_helper"

shared_examples_for "a resource search" do |factory_name|
  describe "component_id" do
    before do
      get(
        request_path,
        headers: { "HOST" => component.organization.host }
      )
    end

    it "only returns resources from the given component" do
      external_resource = create(factory_name)

      expect(subject).not_to have_escaped_html(translated(external_resource.try(:title) || external_resource.try(:name)))
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
    let(:filter_params) { { with_any_scope: scope_ids } }

    let(:scope1) { create :scope, organization: component.organization }
    let(:scope2) { create :scope, organization: component.organization }
    let(:subscope1) { create :scope, organization: component.organization, parent: scope1 }

    let!(:resource) { create(factory_name, { component:, scope: scope1 }.merge(factory_params)) }
    let!(:resource2) { create(factory_name, { component:, scope: scope2 }.merge(factory_params)) }
    let!(:resource3) { create(factory_name, { component:, scope: subscope1 }.merge(factory_params)) }

    before do
      get(
        request_path,
        params: { filter: filter_params },
        headers: { "HOST" => component.organization.host }
      )
    end

    context "when a parent scope id is being sent" do
      let(:scope_ids) { [scope1.id] }

      it "filters resources by scope" do
        expect(subject).to have_escaped_html(translated(resource.try(:title) || resource.try(:name)))
        expect(subject).not_to have_escaped_html(translated(resource2.try(:title) || resource2.try(:name)))
        expect(subject).to have_escaped_html(translated(resource3.try(:title) || resource3.try(:name)))
      end
    end

    context "when a subscope id is being sent" do
      let(:scope_ids) { [subscope1.id] }

      it "filters resources by scope" do
        expect(subject).not_to have_escaped_html(translated(resource.try(:title) || resource.try(:name)))
        expect(subject).not_to have_escaped_html(translated(resource2.try(:title) || resource2.try(:name)))
        expect(subject).to have_escaped_html(translated(resource3.try(:title) || resource3.try(:name)))
      end
    end

    context "when multiple ids are sent" do
      let(:scope_ids) { [scope2.id, scope1.id] }

      it "filters resources by scope" do
        expect(subject).to have_escaped_html(translated(resource.try(:title) || resource.try(:name)))
        expect(subject).to have_escaped_html(translated(resource2.try(:title) || resource2.try(:name)))
        expect(subject).to have_escaped_html(translated(resource3.try(:title) || resource3.try(:name)))
      end
    end

    context "when `global` is being sent" do
      let!(:resource_without_scope) { create(factory_name, { component:, scope: nil }.merge(factory_params)) }
      let(:scope_ids) { ["global"] }

      before do
        get(
          request_path,
          params: { filter: filter_params },
          headers: { "HOST" => component.organization.host }
        )
      end

      it "returns resources without a scope" do
        expect(subject).not_to have_escaped_html(translated(resource.try(:title) || resource.try(:name)))
        expect(subject).not_to have_escaped_html(translated(resource2.try(:title) || resource2.try(:name)))
        expect(subject).not_to have_escaped_html(translated(resource3.try(:title) || resource3.try(:name)))
        expect(subject).to have_escaped_html(translated(resource_without_scope.try(:title) || resource_without_scope.try(:name)))
      end
    end

    context "when `global` and some ids is being sent" do
      let!(:resource_without_scope) { create(factory_name, { component:, scope: nil }.merge(factory_params)) }
      let(:scope_ids) { ["global", scope2.id, scope1.id] }

      before do
        get(
          request_path,
          params: { filter: filter_params },
          headers: { "HOST" => component.organization.host }
        )
      end

      it "returns resources without a scope and with selected scopes" do
        expect(subject).to have_escaped_html(translated(resource_without_scope.try(:title) || resource_without_scope.try(:name)))
        expect(subject).to have_escaped_html(translated(resource.try(:title) || resource.try(:name)))
        expect(subject).to have_escaped_html(translated(resource2.try(:title) || resource2.try(:name)))
        expect(subject).to have_escaped_html(translated(resource3.try(:title) || resource3.try(:name)))
      end
    end
  end
end

shared_examples_for "a resource search with categories" do |factory_name, category_mode = :multi|
  let(:participatory_space) { component.participatory_space }
  let(:filter_params) do
    case category_mode
    when :single
      { with_category: category_ids }
    else
      { with_any_category: category_ids }
    end
  end
  let(:factory_params) do
    resource_params
  rescue StandardError
    {}
  end

  describe "results" do
    let(:category1) { create :category, participatory_space: }
    let(:category2) { create :category, participatory_space: }
    let(:child_category) { create :category, participatory_space:, parent: category2 }
    let!(:resource) { create(factory_name, { component: }.merge(factory_params)) }
    let!(:resource2) { create(factory_name, { component:, category: category1 }.merge(factory_params)) }
    let!(:resource3) { create(factory_name, { component:, category: category2 }.merge(factory_params)) }
    let!(:resource4) { create(factory_name, { component:, category: child_category }.merge(factory_params)) }

    before do
      get(
        request_path,
        params: { filter: filter_params },
        headers: { "HOST" => component.organization.host }
      )
    end

    context "when no category filter is present" do
      let(:category_ids) { nil }

      it "includes all resources" do
        expect(subject).to have_escaped_html(translated(resource.try(:title) || resource.try(:name)))
        expect(subject).to have_escaped_html(translated(resource2.try(:title) || resource2.try(:name)))
        expect(subject).to have_escaped_html(translated(resource3.try(:title) || resource3.try(:name)))
        expect(subject).to have_escaped_html(translated(resource4.try(:title) || resource4.try(:name)))
      end
    end

    context "when a category is selected" do
      let(:category_ids) { [category2.id] }

      it "includes only resources for that category and its children" do
        expect(subject).not_to have_escaped_html(translated(resource.try(:title) || resource.try(:name)))
        expect(subject).not_to have_escaped_html(translated(resource2.try(:title) || resource2.try(:name)))
        expect(subject).to have_escaped_html(translated(resource3.try(:title) || resource3.try(:name)))
        expect(subject).to have_escaped_html(translated(resource4.try(:title) || resource4.try(:name)))
      end
    end

    context "when a subcategory is selected" do
      let(:category_ids) { [child_category.id] }

      it "includes only resources for that category" do
        expect(subject).not_to have_escaped_html(translated(resource.try(:title) || resource.try(:name)))
        expect(subject).not_to have_escaped_html(translated(resource2.try(:title) || resource2.try(:name)))
        expect(subject).not_to have_escaped_html(translated(resource3.try(:title) || resource3.try(:name)))
        expect(subject).to have_escaped_html(translated(resource4.try(:title) || resource4.try(:name)))
      end
    end

    context "when `without` is being sent" do
      let(:category_ids) { ["without"] }

      it "returns resources without a category" do
        expect(subject).to have_escaped_html(translated(resource.try(:title) || resource.try(:name)))
        expect(subject).not_to have_escaped_html(translated(resource2.try(:title) || resource2.try(:name)))
        expect(subject).not_to have_escaped_html(translated(resource3.try(:title) || resource3.try(:name)))
        expect(subject).not_to have_escaped_html(translated(resource4.try(:title) || resource4.try(:name)))
      end
    end

    if category_mode == :multi
      context "when `without` and some category id is being sent" do
        let(:category_ids) { ["without", category1.id] }

        it "returns resources without a category and with the selected category" do
          expect(subject).to have_escaped_html(translated(resource.try(:title) || resource.try(:name)))
          expect(subject).to have_escaped_html(translated(resource2.try(:title) || resource2.try(:name)))
          expect(subject).not_to have_escaped_html(translated(resource3.try(:title) || resource3.try(:name)))
          expect(subject).not_to have_escaped_html(translated(resource4.try(:title) || resource4.try(:name)))
        end
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
  let(:filter_params) { { with_any_origin: origins } }

  describe "results" do
    let!(:official_resource) { create(factory_name, :official, { component: }.merge(factory_params)) }
    let!(:user_group_resource) { create(factory_name, :user_group_author, { component: }.merge(factory_params)) }
    let!(:participant_resource) { create(factory_name, :participant_author, { component: }.merge(factory_params)) }

    if FactoryBot.factory_by_name(factory_name).defined_traits.map(&:name).include?(:meeting_resource)
      let!(:meeting_resource) { create(factory_name, :official_meeting, { component: }.merge(factory_params)) }
    end

    before do
      get(
        request_path,
        params: { filter: filter_params },
        headers: { "HOST" => component.organization.host }
      )
    end

    context "when filtering official resources" do
      let(:origins) { %w(official) }

      it "returns only official resources" do
        expect(subject).to have_escaped_html(translated(official_resource.try(:title) || official_resource.try(:name)))
        expect(subject).not_to have_escaped_html(translated(participant_resource.try(:title) || participant_resource.try(:name)))
        expect(subject).not_to have_escaped_html(translated(user_group_resource.try(:title) || user_group_resource.try(:name)))
      end
    end

    context "when filtering participants resources" do
      let(:origins) { %w(participants) }

      it "returns only citizen resources" do
        expect(subject).not_to have_escaped_html(translated(official_resource.try(:title) || official_resource.try(:name)))
        expect(subject).to have_escaped_html(translated(participant_resource.try(:title) || participant_resource.try(:name)))
        expect(subject).not_to have_escaped_html(translated(user_group_resource.try(:title) || user_group_resource.try(:name)))
      end
    end

    context "when filtering user groups resources" do
      let(:origins) { %w(user_group) }

      it "returns only user groups resources" do
        expect(subject).not_to have_escaped_html(translated(official_resource.try(:title) || official_resource.try(:name)))
        expect(subject).not_to have_escaped_html(translated(participant_resource.try(:title) || participant_resource.try(:name)))
        expect(subject).to have_escaped_html(translated(user_group_resource.try(:title) || user_group_resource.try(:name)))
      end
    end

    if respond_to?(:meeting_resource)
      context "when filtering meetings resources" do
        let(:origins) { %w(meeting) }

        it "returns only meeting resources" do
          expect(subject).not_to have_escaped_html(translated(official_resource.try(:title) || official_resource.try(:name)))
          expect(subject).not_to have_escaped_html(translated(participant_resource.try(:title) || participant_resource.try(:name)))
          expect(subject).not_to have_escaped_html(translated(user_group_resource.try(:title) || user_group_resource.try(:name)))
          expect(subject).to have_escaped_html(translated(meeting_resource.try(:title) || meeting_resource.try(:name)))
        end
      end
    end
  end
end
