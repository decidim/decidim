SELECT
  proposals.id AS proposal_id,
  proposals.state AS state,
  proposals.category_id AS category_id,
  components.decidim_participatory_space_type AS participatory_space_type,
  components.decidim_participatory_space_id AS participatory_space_id,
  proposals.decidim_organization_id AS organization_id,
  proposals.created_at AS created_at
FROM dedicim_proposals_proposals AS proposals
LEFT JOIN decidim_components AS components ON components.id = proposals.decidim_component_id
LEFT JOIN decidim_moderations AS moderations ON moderations.decidim_reportable_type = "Decidim::Proposals::Proposal" AND moderations.decidim_reportable_id = proposals.id
WHERE
  proposals.published_at IS NOT NULL AND
  (proposals.state IS NOT NULL OR proposals.state != "withdrawn") AND
  moderations.hidden_at IS NULL
