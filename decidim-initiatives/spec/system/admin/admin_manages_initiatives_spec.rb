# frozen_string_literal: true

require "spec_helper"

describe "Admin manages initiatives", type: :system do
  STATES = Decidim::Initiative.states.keys.map(&:to_sym)

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, :admin, organization:) }
  let(:model_name) { Decidim::Initiative.model_name }
  let(:resource_controller) { Decidim::Initiatives::Admin::InitiativesController }
  let(:type1) { create :initiatives_type, organization: }
  let(:type2) { create :initiatives_type, organization: }
  let(:scoped_type1) { create :initiatives_type_scope, type: type1 }
  let(:scoped_type2) { create :initiatives_type_scope, type: type2 }
  let(:area1) { create :area, organization: }
  let(:area2) { create :area, organization: }

  def create_initiative_with_trait(trait)
    create(:initiative, trait, organization:)
  end

  def initiative_with_state(state)
    Decidim::Initiative.find_by(state:)
  end

  def initiative_without_state(state)
    Decidim::Initiative.where.not(state:).sample
  end

  def initiative_with_type(type)
    Decidim::Initiative.join(:scoped_type).find_by(decidim_initiatives_types_id: type)
  end

  def initiative_without_type(type)
    Decidim::Initiative.join(:scoped_type).where.not(decidim_initiatives_types_id: type).sample
  end

  def initiative_with_area(area)
    Decidim::Initiative.find_by(decidim_area_id: area)
  end

  def initiative_without_area(area)
    Decidim::Initiative.where.not(decidim_area_id: area).sample
  end

  include_context "with filterable context"

  STATES.each do |state|
    let!("#{state}_initiative".to_sym) { create_initiative_with_trait(state) }
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_initiatives.initiatives_path
  end

  describe "listing initiatives" do
    STATES.each do |state|
      i18n_state = I18n.t(state, scope: "decidim.admin.filters.initiatives.state_eq.values")

      context "filtering collection by state: #{i18n_state}" do
        it_behaves_like "a filtered collection", options: "State", filter: i18n_state do
          let(:in_filter) { translated(initiative_with_state(state).title) }
          let(:not_in_filter) { translated(initiative_without_state(state).title) }
        end
      end
    end

    Decidim::InitiativesTypeScope.all.each do |scoped_type|
      type = scoped_type.type
      i18n_type = type.title[I18n.locale.to_s]

      context "filtering collection by type: #{i18n_type}" do
        before do
          create(:initiative, organization:, scoped_type: scoped_type1)
          create(:initiative, organization:, scoped_type: scoped_type2)
        end

        it_behaves_like "a filtered collection", options: "Type", filter: i18n_type do
          let(:in_filter) { translated(initiative_with_type(type).title) }
          let(:not_in_filter) { translated(initiative_without_type(type).title) }
        end
      end
    end

    it "can be searched by title" do
      search_by_text(translated(published_initiative.title))

      expect(page).to have_content(translated(published_initiative.title))
    end

    Decidim::Area.all.each do |area|
      i18n_area = area.name[I18n.locale.to_s]

      context "filtering collection by area: #{i18n_area}" do
        before do
          create(:initiative, organization:, area: area1)
          create(:initiative, organization:, area: area2)
        end

        it_behaves_like "a filtered collection", options: "Area", filter: i18n_area do
          let(:in_filter) { translated(initiative_with_area(area).title) }
          let(:not_in_filter) { translated(initiative_without_area(area).title) }
        end
      end
    end

    it "can be searched by description" do
      search_by_text(translated(published_initiative.description))

      expect(page).to have_content(translated(published_initiative.title))
    end

    it "can be searched by id" do
      search_by_text(published_initiative.id)

      expect(page).to have_content(translated(published_initiative.title))
    end

    it "can be searched by author name" do
      search_by_text(published_initiative.author.name)

      expect(page).to have_content(translated(published_initiative.title))
    end

    it "can be searched by author nickname" do
      search_by_text(published_initiative.author.nickname)

      expect(page).to have_content(translated(published_initiative.title))
    end

    it_behaves_like "paginating a collection"
  end
end
