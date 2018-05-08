class AddProposalModeration < ActiveRecord::Migration[5.1]
  def up
    Decidim::Comments::Comment.all.each {|c|Decidim::Moderation.find_or_create_by!(reportable: c, participatory_space: c.feature.participatory_space, upstream_moderation: "authorized")}

    Decidim::Proposals::Proposal.all.each {|p|Decidim::Moderation.find_or_create_by!(reportable: p, participatory_space: p.feature.participatory_space, upstream_moderation: "authorized")}

    Decidim::Moderation.all.each {|m| m.update_attributes(upstream_moderation: "authorized")}
  end

  def down; end
end
