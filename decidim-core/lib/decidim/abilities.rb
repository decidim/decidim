# frozen_string_literal: true

module Decidim
  module Abilities
    autoload :AdminAbility, "decidim/abilities/admin_ability"
    autoload :ParticipatoryProcessRoleAbility, "decidim/abilities/participatory_process_role_ability"
    autoload :ParticipatoryProcessAdminAbility, "decidim/abilities/participatory_process_admin_ability"
    autoload :ParticipatoryProcessCollaboratorAbility, "decidim/abilities/participatory_process_collaborator_ability"
    autoload :ParticipatoryProcessModeratorAbility, "decidim/abilities/participatory_process_moderator_ability"
  end
end
