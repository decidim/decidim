# frozen_string_literal: true

require "spec_helper"
require_relative "../../db/migrate/20191217053731_remove_duplicate_group_endorsements"

describe RemoveDuplicateGroupEndorsements do
  let!(:organization) { create(:organization) }
  let!(:component) { create(:component, organization: organization, manifest_name: "proposals") }
  let!(:participatory_process) { create(:participatory_process, organization: organization) }

  let!(:author) { create(:user, organization: organization) }
  let!(:another_author) { create(:user, organization: organization) }

  let!(:individual_author) { create(:user, organization: organization) }
  let!(:another_individual_author) { create(:user, organization: organization) }

  let!(:user_group) { create(:user_group, verified_at: Time.current, organization: organization, users: [author, another_author]) }

  let!(:proposal) { create(:proposal, component: component, users: [author]) }

  let!(:group_endorsement) do
    create(:proposal_endorsement, proposal: proposal, author: author,
                                  user_group: user_group)
  end

  let!(:duplicate_group_endorsement) do
    create(:proposal_endorsement, proposal: proposal, author: another_author,
                                  user_group: user_group)
  end

  let!(:personal_endorsement) do
    create(:proposal_endorsement, proposal: proposal, author: individual_author)
  end

  let!(:another_personal_endorsement) do
    create(:proposal_endorsement, proposal: proposal, author: another_individual_author)
  end

  it "removes duplicate group endorsements, leaving the first one" do
    RemoveDuplicateGroupEndorsements.new.change

    expect(Decidim::Proposals::ProposalEndorsement.where(id: group_endorsement.id)).to exist
    expect(Decidim::Proposals::ProposalEndorsement.where(id: duplicate_group_endorsement.id)).not_to exist
  end

  it "does not remove personal endorsements" do
    RemoveDuplicateGroupEndorsements.new.change

    expect(Decidim::Proposals::ProposalEndorsement.where(id: personal_endorsement.id)).to exist
    expect(Decidim::Proposals::ProposalEndorsement.where(id: another_personal_endorsement.id)).to exist
  end
end
