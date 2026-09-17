# frozen_string_literal: true

describe "Instructeurs::DossiersController#create_avis", type: :request do
  let(:procedure) { procedures.individual }
  let(:email) { "expert-non-autorise@exemple.fr" }

  before { login_as(instructeurs.default.user, scope: :user) }

  subject do
    post avis_instructeur_dossier_path(procedure_id: procedure.id, dossier_id: dossier.id),
      params: { avis: { emails: [email], introduction: "Votre avis ?" } }
  end

  shared_examples "a refused avis request" do |alert_key|
    it do
      expect { subject }.not_to change { dossier.avis.count }
      expect(response).to have_http_status(:forbidden)
      expect(flash[:alert]).to eq(I18n.t(alert_key))
      expect(User.exists?(email:)).to be(false)
    end
  end

  context "when the procedure disallows expert review" do
    let(:dossier) { dossiers.en_instruction }

    before { procedure.update!(allow_expert_review: false) }

    it_behaves_like "a refused avis request", 'helpers.information_text.unauthorized_avis_text'
  end

  context "when the dossier is termine" do
    let(:dossier) { dossiers.accepte }

    it_behaves_like "a refused avis request", 'helpers.information_text.no_new_avis_text'
  end
end
