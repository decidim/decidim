# frozen_string_literal: true

require "spec_helper"

describe "Admin manages results", type: :system do
    include_context "with a component"

#   STATES = Decidim::Accountability::Result.states.keys.map(&:to_sym)

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, organization: organization) }
#   let(:model_name) { Decidim::Accountability::Result.model_name }
#   let(:type1) { create :results_type, organization: organization }
#   let(:type2) { create :results_type, organization: organization }
#   let(:scoped_type1) { create :results_type_scope, type: type1 }
#   let(:scoped_type2) { create :results_type_scope, type: type2 }
#   let(:area1) { create :area, organization: organization }
#   let(:area2) { create :area, organization: organization }

#   def create_result_with_trait(trait)
#     create(:result, trait, organization: organization)
#   end

#   def result_with_state(state)
#     Decidim::Accountability::Result.find_by(state: state)
#   end

#   def result_without_state(state)
#     Decidim::Accountability::Result.where.not(state: state).sample
#   end

#   def result_with_type(type)
#     Decidim::Accountability::Result.join(:scoped_type).find_by(decidim_results_types_id: type)
#   end

#   def result_without_type(type)
#     Decidim::Accountability::Result.join(:scoped_type).where.not(decidim_results_types_id: type).sample
#   end

#   def result_with_area(area)
#     Decidim::Accountability::Result.find_by(decidim_area_id: area)
#   end

#   def result_without_area(area)
#     Decidim::Accountability::Result.where.not(decidim_area_id: area).sample
#   end

  include_context "with filterable context"

#   STATES.each do |state|
#     let!("#{state}_result".to_sym) { create_result_with_trait(state) }
#   end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
# byebug    
    # visit decidim_accountability_admin.results_path
    visit path
  end

  describe "listing results" do
    # STATES.each do |state|
    #   i18n_state = I18n.t(state, scope: "decidim.admin.filters.results.state_eq.values")

    #   context "filtering collection by state: #{i18n_state}" do
    #     it_behaves_like "a filtered collection", options: "State", filter: i18n_state do
    #       let(:in_filter) { translated(result_with_state(state).title) }
    #       let(:not_in_filter) { translated(result_without_state(state).title) }
    #     end
    #   end
    # end

    # Decidim::resultsTypeScope.all.each do |scoped_type|
    #   type = scoped_type.type
    #   i18n_type = type.title[I18n.locale.to_s]

    #   context "filtering collection by type: #{i18n_type}" do
    #     before do
    #       create(:result, organization: organization, scoped_type: scoped_type1)
    #       create(:result, organization: organization, scoped_type: scoped_type2)
    #     end

    #     it_behaves_like "a filtered collection", options: "Type", filter: i18n_type do
    #       let(:in_filter) { translated(result_with_type(type).title) }
    #       let(:not_in_filter) { translated(result_without_type(type).title) }
    #     end
    #   end
    # end

    # let(:path) { decidim_participatory_process_accountability.results_path(participatory_process_slug: participatory_process.slug, component_id: component.id) }
    let(:path) { decidim_admin_participatory_process_accountability.results_path(participatory_process_slug: participatory_process.slug, component_id: component.id) }

    it "can be searched by title" do
      search_by_text(translated(published_result.title))

      expect(page).to have_content(translated(published_result.title))
    end

    # Decidim::Area.all.each do |area|
    #   i18n_area = area.name[I18n.locale.to_s]

    #   context "filtering collection by area: #{i18n_area}" do
    #     before do
    #       create(:result, organization: organization, area: area1)
    #       create(:result, organization: organization, area: area2)
    #     end

    #     it_behaves_like "a filtered collection", options: "Area", filter: i18n_area do
    #       let(:in_filter) { translated(result_with_area(area).title) }
    #       let(:not_in_filter) { translated(result_without_area(area).title) }
    #     end
    #   end
    # end

    # it "can be searched by description" do
    #   search_by_text(translated(published_result.description))

    #   expect(page).to have_content(translated(published_result.title))
    # end

    # it "can be searched by id" do
    #   search_by_text(published_result.id)

    #   expect(page).to have_content(translated(published_result.title))
    # end

    # it "can be searched by author name" do
    #   search_by_text(published_result.author.name)

    #   expect(page).to have_content(translated(published_result.title))
    # end

    # it "can be searched by author nickname" do
    #   search_by_text(published_result.author.nickname)

    #   expect(page).to have_content(translated(published_result.title))
    # end

    # it_behaves_like "paginating a collection"
  end
end
