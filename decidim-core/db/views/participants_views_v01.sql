SELECT
  decidim_users.id AS user_id,
  decidim_users.decidim_organization_id AS organization_id,
  decidim_users.created_at AS created_at
FROM decidim_users
WHERE
  decidim_users.deleted_at IS NULL AND
  decidim_users.confirmed_at IS NOT NULL AND
  decidim_users.managed = false
