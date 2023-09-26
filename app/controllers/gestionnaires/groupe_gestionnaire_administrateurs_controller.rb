module Gestionnaires
  class GroupeGestionnaireAdministrateursController < GestionnaireController
    before_action :retrieve_groupe_gestionnaire

    def create
      email = params.require(:administrateur)[:email]&.strip&.downcase
      # Find the admin
      administrateur = Administrateur.by_email(email)
      if administrateur.nil?
        flash.alert = "L’administrateur « #{email} » n’existe pas. Invitez-le à demander un compte administrateur à l’adresse <a href=#{DEMANDE_INSCRIPTION_ADMIN_PAGE_URL}>#{DEMANDE_INSCRIPTION_ADMIN_PAGE_URL}</a>."
        return
      end

      # Prevent duplicates (also enforced in the database in administrateurs_procedures)
      if @groupe_gestionnaire.administrateurs.include?(administrateur)
        flash.alert = "L’administrateur « #{administrateur.email} » est déjà gestionnaire de « #{@groupe_gestionnaire.name} »."
        return
      end

      # Actually add the admin
      @groupe_gestionnaire.administrateurs << administrateur
      @administrateur = administrateur
      flash.notice = "L’administrateur « #{administrateur.email} » a été ajouté à au groupe « #{@groupe_gestionnaire.name} »."
    end

    def destroy
      admin_to_delete = @groupe_gestionnaire.administrateurs.find(params[:id])

      begin
        # Actually remove the admin
        @groupe_gestionnaire.administrateurs.delete(admin_to_delete)
        @administrateur = admin_to_delete
        flash.notice = "L’administrateur \« #{admin_to_delete.email} » a été retiré du groupe « #{@groupe_gestionnaire.name} »."

        if current_gestionnaire == admin_to_delete
          redirect_to gestionnaire_groupe_gestionnaires_path
        end
      rescue ActiveRecord::ActiveRecordError => e
        flash.alert = e.message
      end
    end
  end
end
