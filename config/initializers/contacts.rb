if !defined?(CONTACT_EMAIL)
  CONTACT_EMAIL = ENV.fetch("CONTACT_EMAIL", "contact@demarches-simplifiees.fr")
  EQUIPE_EMAIL = ENV.fetch("EQUIPE_EMAIL", "equipe@demarches-simplifiees.fr")
  TECH_EMAIL = ENV.fetch("TECH_EMAIL", "tech@demarches-simplifiees.fr")
  NO_REPLY_EMAIL = ENV.fetch("NO_REPLY_EMAIL", "Ne pas répondre <ne-pas-repondre@demarches-simplifiees.fr>")
  CONTACT_PHONE = ENV.fetch("CONTACT_PHONE", "01 76 42 02 87")

  OLD_CONTACT_EMAIL = ENV.fetch("OLD_CONTACT_EMAIL", "contact@tps.apientreprise.fr")
end
