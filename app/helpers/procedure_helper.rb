module ProcedureHelper
  def procedure_lien(procedure)
    if procedure.brouillon?
      commencer_test_url(path: procedure.path)
    else
      commencer_url(path: procedure.path)
    end
  end

  def procedure_libelle(procedure)
    parts = procedure.brouillon? ? [tag.span('démarche en test', class: 'badge')] : []
    parts << procedure.libelle
    safe_join(parts, ' ')
  end

  def procedure_publish_text(procedure, key)
    # i18n-tasks-use t('modal.publish.body.publish')
    # i18n-tasks-use t('modal.publish.body.reopen')
    # i18n-tasks-use t('modal.publish.submit.publish')
    # i18n-tasks-use t('modal.publish.submit.reopen')
    # i18n-tasks-use t('modal.publish.title.publish')
    # i18n-tasks-use t('modal.publish.title.reopen')
    action = procedure.close? ? :reopen : :publish
    t(action, scope: [:modal, :publish, key])
  end

  def types_de_champ_data(procedure)
    {
      isAnnotation: false,
      typeDeChampsTypes: TypeDeChamp.type_de_champ_types_for(procedure, current_user),
      typeDeChamps: (procedure.draft_revision ? procedure.draft_revision : procedure).types_de_champ.as_json_for_editor,
      baseUrl: admin_procedure_types_de_champ_path(procedure),
      directUploadUrl: rails_direct_uploads_url
    }
  end

  def types_de_champ_private_data(procedure)
    {
      isAnnotation: true,
      typeDeChampsTypes: TypeDeChamp.type_de_champ_types_for(procedure, current_user),
      typeDeChamps: (procedure.draft_revision ? procedure.draft_revision : procedure).types_de_champ_private.as_json_for_editor,
      baseUrl: admin_procedure_types_de_champ_path(procedure),
      directUploadUrl: rails_direct_uploads_url
    }
  end

  def procedure_auto_archive_date(procedure)
    I18n.l(procedure.auto_archive_on - 1.day, format: '%-d %B %Y')
  end

  def procedure_auto_archive_time(procedure)
    "à 23 h 59 (heure de " + Rails.application.config.time_zone + ")"
  end

  def procedure_auto_archive_datetime(procedure)
    procedure_auto_archive_date(procedure) + ' ' + procedure_auto_archive_time(procedure)
  end

  def api_particulier_sources_li(key, value, checked, label)
    concat(tag.li do
      concat(tag.label do
        concat(check_box key, value, checked: ActiveModel::Type::Boolean.new.cast(checked))
        concat(t(label))
      end)
    end)
  end

  def api_particulier_sources_checkbox(hash, parent, child)
    if hash[parent.to_sym] && hash[parent.to_sym][child.to_sym]
      source = hash[parent.to_sym][child.to_sym]
      capture do
        concat(tag.strong(t("api_particulier.entities.#{parent}.#{child}.libelle", default: "").capitalize))
        concat(tag.ul(class: "procedure-admin-api-particulier-sources") do
          source.each do |key, value|
            if value.is_a?(Hash)
              concat(tag.strong(t("api_particulier.entities.#{parent}.#{child}.#{key}_libelle").capitalize))
              concat(tag.ul(class: "procedure-admin-api-particulier-sources") do
                value.each do |k, v|
                  if v.is_a?(Hash)
                    concat(tag.strong(t("api_particulier.entities.#{parent}.#{child}.#{key}.#{k}_libelle").capitalize))
                    concat(tag.ul(class: "procedure-admin-api-particulier-sources") do
                      v.each do |kk, vv|
                        api_particulier_sources_li("procedure[#{parent}][#{child}][#{key}][#{k}]", kk, vv, "api_particulier.entities.#{parent}.#{child}.#{key}.#{k}.#{kk}")
                      end
                    end)
                  else
                    api_particulier_sources_li("procedure[#{parent}][#{child}][#{key}]", k, v, "api_particulier.entities.#{parent}.#{child}.#{key}.#{k}")
                  end
                end
              end)
            else
              api_particulier_sources_li("procedure[#{parent}][#{child}]", key, value, "api_particulier.entities.#{parent}.#{child}.#{key}")
            end
          end
        end)
      end
    end
  end
end
