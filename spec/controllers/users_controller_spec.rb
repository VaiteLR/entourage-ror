require 'rails_helper'
include AuthHelper
include Requests::JsonHelpers

RSpec.describe UsersController, :type => :controller do
  render_views
  
  describe 'users login' do
    let!(:user) { create :user }
    subject { assigns(:user) }

    context 'when user email is valid' do
      let(:another_user) { create :user, email: 'another_user@mail.com' }
      before { post 'login', email: another_user.email, format: 'json' }
      it { should eq another_user }
    end

    context 'when user does not exist' do
      before { post 'login', email: 'not_existing@nowhere.com', format: 'json' }
      it { should be nil }
    end

  end

  describe 'get index' do

    context 'without basic authentication' do
      it "retuns 401" do
        get 'index', :format => :json
        expect(response.status).to eq(401)
      end
    end
    
    context 'without any user' do
      it "retuns 200" do
        admin_basic_login
        get 'index', :format => :json
        expect(response.status).to eq(200)
      end

      it "assigns empty array" do
        admin_basic_login
        get 'index', :format => :json
        expect(assigns(:users)).to match_array([])
      end

      it 'returns empty array' do
        admin_basic_login
        get 'index', :format => :json
        expect(json["users"]).to match_array([])
      end

    end

    context 'with one user' do
      it 'assigns array with user' do
        admin_basic_login
        user = FactoryGirl.create(:user)
        get 'index', :format => :json
        expect(assigns(:users)).to match_array([user])
      end

      it 'returns array with one user' do
        admin_basic_login
        user = FactoryGirl.create(:user)
        get 'index', :format => :json
        expect(json["users"]).to match_array([{"id" => user.id,"email"=>user.email,"first_name"=>user.first_name, "last_name"=>user.last_name}])
      end
    end

  end

  describe 'post create' do

    context 'without basic authentication' do
      it "retuns 401" do
        post 'create', :format => :json
        expect(response.status).to eq(401)
      end
    end
    
    context 'with incorrect parameters' do
      it "retuns 400" do
        admin_basic_login
        post 'create', user: {key: "value"}, format: :json
        expect(response.status).to eq(400)
      end
    end

    context 'without correct parameters' do
      it "retuns 201" do
        admin_basic_login
        post 'create', user: {email: "test@rspec.com", first_name:"tester", last_name:"tested"}, format: :json
        expect(response.status).to eq(201)
      end

      it "creates new user" do
        admin_basic_login
        user_count = User.count
        post 'create', user: {email: "test@rspec.com", first_name:"tester", last_name:"tested"}, format: :json
        expect(User.count).to eq(user_count + 1)
      end
    end

  end


  describe 'put update' do
    
    context 'with incorrect user id' do
      it "retuns 404" do
        admin_basic_login
        put 'update', id: 1, user: {key: "value"}, format: :json
        expect(response.status).to eq(404)
      end
    end

    context 'with correct user id and parameters' do
      it "retuns 200" do
        admin_basic_login
        user = FactoryGirl.create(:user)
        put 'update', id: user.id, user: {email: "change#{user.email}", first_name:"change#{user.first_name}", last_name:"change#{user.last_name}"}, format: :json
        expect(response.status).to eq(200)
      end

      it "changes user attributes" do
        admin_basic_login
        initial_user = FactoryGirl.create(:user)
        put 'update', id: initial_user.id, user: {email: "change#{initial_user.email}", first_name:"change#{initial_user.first_name}", last_name:"change#{initial_user.last_name}"}, format: :json
        changed_user = User.find(initial_user.id)
        expect(changed_user.email).to eq("change#{initial_user.email}")
        expect(changed_user.first_name).to eq("change#{initial_user.first_name}")
        expect(changed_user.last_name).to eq("change#{initial_user.last_name}")
      end
    end

  end

  describe 'delete destroy' do
    
    context 'with incorrect user id' do
      it "retuns 404" do
        admin_basic_login
        delete 'destroy', id: 1, format: :json
        expect(response.status).to eq(404)
      end
    end

    context 'with correct user id' do
      it "retuns 204" do
        admin_basic_login
        user = FactoryGirl.create(:user)
        delete 'destroy', id: user.id, format: :json
        expect(response.status).to eq(204)
      end

      it "destroys user" do
        admin_basic_login
        user = FactoryGirl.create(:user)
        delete 'destroy', id: user.id, format: :json
        deleted_user = User.find_by(id: user.id)
        expect(deleted_user).to eq(nil)
      end
    end

  end

end
