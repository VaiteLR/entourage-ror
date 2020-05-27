require 'rails_helper'

RSpec.describe Api::V1::PartnersController, type: :controller do

  let!(:user) { FactoryGirl.create :pro_user }

  describe 'GET index' do
    let!(:partner1) { FactoryGirl.create(:partner, name: "Partner B") }
    let!(:partner2) { FactoryGirl.create(:partner, name: "Partner A", postal_code: "75008") }
    # before { FactoryGirl.create(:user_partner, user: user, partner: partner1) }

    before { get 'index', token: user.token }
    # TODO(partner)
    it { expect(JSON.parse(response.body)).to eq(
      {"partners"=>[
        {
          "id"=>partner2.id,
          "name"=>"Partner A",
          "postal_code"=>"75008"
        },
        {
          "id"=>partner1.id,
          "name"=>"Partner B",
          "postal_code"=>nil
        }
      ]}
    )}
  end

  describe 'POST join_request' do
    before { post :join_request, {token: user.token, postal_code: "75008", partner_role_title: "Senior VP of Meme Warfare"}.merge(params) }
    let(:join_request) { user.partner_join_requests.last }

    describe 'new partner' do
      let(:params) { {new_partner_name: "New"} }
      it { expect(response.status).to eq 200 }
      it { expect(join_request.attributes).to include(
        "user_id"=>user.id,
        "partner_id"=>nil,
        "new_partner_name"=>"New",
        "postal_code"=>"75008",
        "partner_role_title"=>"Senior VP of Meme Warfare"
      )}
    end

    describe 'existing partner' do
      let(:params) { {partner_id: 42} }
      it { expect(response.status).to eq 200 }
      it { expect(join_request.attributes).to include(
        "user_id"=>user.id,
        "partner_id"=>42,
        "new_partner_name"=>nil,
        "postal_code"=>"75008",
        "partner_role_title"=>"Senior VP of Meme Warfare"
      )}
    end

    describe 'both parameters' do
      let(:params) { {partner_id: 42, new_partner_name: "New"} }
      it { expect(response.status).to eq 400 }
      it { expect(JSON.parse(response.body)).to eq(
        "error" => {
          "code" => "INVALID_PARTNER_JOIN_REQUEST",
          "message" => ["Partner 'new_partner_name' must be nil when 'partner_id' is present"]
        }
      )}
    end

    describe 'neither parameters' do
      let(:params) { {} }
      it { expect(response.status).to eq 400 }
      it { expect(JSON.parse(response.body)).to eq(
        "error" => {
          "code" => "INVALID_PARTNER_JOIN_REQUEST",
          "message" => ["Partner 'partner_id' or 'new_partner_name' must be present"]
        }
      )}
    end
  end
end
