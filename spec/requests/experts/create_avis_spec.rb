# frozen_string_literal: true

describe "Experts::AvisController#create_avis", type: :request do
  let(:procedure) { procedures.individual }
  let(:dossier) { avis_source.dossier }
  let(:email) { "expert-non-autorise@exemple.fr" }

  before { login_as(experts.default.user, scope: :user) }

  subject do
    post avis_expert_avis_path(procedure_id: procedure.id, id: avis_source.id),
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
    let(:avis_source) { avis.pending }

    before { procedure.update!(allow_expert_review: false) }

    it_behaves_like "a refused avis request", 'helpers.information_text.unauthorized_avis_text'
  end

  context "when the dossier is termine" do
    let(:avis_source) { avis.answered }

    it_behaves_like "a refused avis request", 'helpers.information_text.no_new_avis_text'
  end
end
