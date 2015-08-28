require 'rails_helper'

describe PoisController, :type => :controller do
  render_views
  
  context 'authorized' do
    let!(:user) { create :user }
    describe '#index' do
      context 'without parameters' do
        let!(:category1) { create :category }
        let!(:category2) { create :category }
        let!(:poi1) { create :poi, category: category1, validated: true }
        let!(:poi2) { create :poi, category: category1, validated: false }
        let!(:poi3) { create :poi, category: category1, validated: true }
        before { get 'index', token: user.token, :format => :json }
        it { expect(assigns(:categories)).to eq([category1, category2]) }
        it { expect(assigns(:pois)).to eq([poi1, poi3]) }
      end
      context 'with location parameters' do
        let!(:poi1) { create :poi, latitude: 10, longitude: 12 }
        let!(:poi2) { create :poi, latitude: 9.9, longitude: 10.1 }
        let!(:poi3) { create :poi, latitude: 10, longitude: 10 }
        let!(:poi4) { create :poi, latitude: 10.05, longitude: 9.95 }
        let!(:poi5) { create :poi, latitude: 12, longitude: 10 }
        context 'without distance' do
          before { get :index, token: user.token, latitude: 10.0, longitude: 10.0, format: :json }
          it { should respond_with 200 }
          it { expect(assigns[:pois]).to eq [poi3, poi4] }
        end
        context 'with distance' do
          before { get :index, token: user.token, latitude: 10.0, longitude: 10.0, distance: 20.0, format: :json }
          it { should respond_with 200 }
          it { expect(assigns[:pois]).to eq [poi2, poi3, poi4] }
        end
      end
    end
    
    describe '#create' do
      let!(:poi) { build :poi }
      before { post :create, token: user.token, poi: { name: poi.name, latitude: poi.latitude, longitude: poi.longitude, adress: poi.adress, phone: poi.phone, website: poi.website, email: poi.email, audience: poi.audience, category_id: poi.category_id }, format: :json}
      it { should respond_with 201 }
      it { expect(Poi.unscoped.last.name).to eq poi.name }
      it { expect(Poi.unscoped.last.latitude).to eq poi.latitude }
      it { expect(Poi.unscoped.last.longitude).to eq poi.longitude }
      it { expect(Poi.unscoped.last.adress).to eq poi.adress }
      it { expect(Poi.unscoped.last.phone).to eq poi.phone }
      it { expect(Poi.unscoped.last.website).to eq poi.website }
      it { expect(Poi.unscoped.last.email).to eq poi.email }
      it { expect(Poi.unscoped.last.audience).to eq poi.audience }
      it { expect(Poi.unscoped.last.category).to eq poi.category }
      it { expect(Poi.unscoped.last.validated).to be false }
    end
    
    describe '#report' do
      let!(:poi) { create :poi }
      let!(:mail) { spy('mail') }
      let!(:member_mailer) { spy('member_mailer', poi_report: mail) }
      let!(:message) { 'message' }
      describe 'correct request' do
        before do
          controller.member_mailer = member_mailer
          post :report, id: poi.id, token: user.token, message: message, format: :json
        end
        it { should respond_with 201 }
        it { expect(member_mailer).to have_received(:poi_report).with poi, user, message }
        it { expect(mail).to have_received(:deliver_later).with no_args }
      end
      describe 'wrong poi id' do
        before { post :report, id: -1, token: user.token, message: message, format: :json }
        it { should respond_with 404 }
      end
      describe 'no message' do
        before { post :report, id: poi.id, token: user.token, format: :json }
        it { should respond_with 400 }
      end
    end
    
  end
    
  context "unauthorized" do
    describe '#index' do
      before { get 'index', :format => :json }
      it { should respond_with 401 }
    end
  end
end
