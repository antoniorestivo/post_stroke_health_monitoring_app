require "rails_helper"

RSpec.describe "Authentication", type: :request do
  let!(:user) { User.create!(email: "user@example.com", password: "longer_password",
                             password_confirmation: "longer_password", email_confirmed:) }
  let(:login_path) { "/api/sessions" }
  let(:protected_users_me_path) { "/api/users/me" }
  let(:protected_conditions_path) { "/api/conditions/" }
  let(:jwt_secret) { ENV["JWT_SECRET_KEY"] || Rails.application.secret_key_base }
  let(:issuer) { "test-issuer" }
  let(:audience) { "test-audience" }
  let(:email_confirmed) { true }

  def auth_header(token)
    { "Authorization" => "Bearer #{token}" }
  end

  def generate_token(payload = {})
    now = Time.now.to_i
    default_claims = {
      user_id: user.id,
      exp: now + 1.hour.to_i
    }
    JWT.encode(default_claims.merge(payload), jwt_secret, "HS256")
  end

  describe "login /api/sessions" do
    context "with valid credentials + email confirmed" do
      it "returns a JWT and basic user data without sensitive fields" do
        post login_path, params: { email: user.email, password: "longer_password" }

        expect(response).to have_http_status(:created).or have_http_status(:ok)

        body = JSON.parse(response.body)
        expect(body["jwt"]).to be_present
        expect(body["user"]).to be_present
        expect(body["user"]["email"]).to eq(user.email)
        expect(body["user"]).not_to have_key("password")
        expect(body["user"]).not_to have_key("password_digest")
      end
    end

    context "with invalid credentials" do
      it "returns 401 for wrong password" do
        post login_path, params: { email: user.email, password: "wrongpass" }

        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body) rescue {}
        expect(body["error"]).to be_present
      end

      it "returns 401 for unknown email" do
        post login_path, params: { email: "nope@example.com", password: "longer_password" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "protected endpoints require authentication" do
    it "returns 401 when no token is provided" do
      get protected_users_me_path

      expect(response).to have_http_status(:unauthorized)
      body = JSON.parse(response.body) rescue {}
      expect(body["error"]).to be_present
    end

    it "returns 401 when malformed Authorization header is provided" do
      get protected_users_me_path, headers: { "Authorization" => "Token abc" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "allows access with a valid token" do
      token = generate_token
      get protected_users_me_path, headers: auth_header(token)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["email"]).to eq(user.email).or eq(user.reload.email)
    end
  end

  describe "JWT validation" do
    it "rejects expired tokens" do
      token = generate_token(exp: Time.now.to_i - 60)
      get protected_users_me_path, headers: auth_header(token)

      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects tokens signed with the wrong secret" do
      now = Time.now.to_i
      payload = {
        sub: user.id,
        exp: now + 1.hour.to_i,
        iat: now,
        iss: issuer,
        aud: audience
      }
      tampered_token = JWT.encode(payload, "wrong-secret", "HS256")

      get protected_users_me_path, headers: auth_header(tampered_token)

      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects completely invalid token strings" do
      get protected_users_me_path, headers: auth_header("not-a-jwt")

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "authorization and ownership" do
    let!(:other_user) { User.create!(email: "other@example.com", password: "longer_password",
                                     password_confirmation: "longer_password") }
    let!(:user_condition) { Condition.create!(name: "Mine", user: user) }
    let!(:other_condition) { Condition.create!(name: "NotMine", user: other_user) }

    it "lists only the current user's resources" do
      token = generate_token

      get protected_conditions_path, headers: auth_header(token), as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      names = body.map { |c| c["name"] } rescue []
      expect(names).to include("Mine")
      expect(names).not_to include("NotMine")
    end

    it "prevents access to another user's resource by id" do
      token = generate_token
      path = "#{protected_conditions_path}/#{other_condition.id}"

      get path, headers: auth_header(token), as: :json

      expect(response).to satisfy { |r| [403, 404].include?(r.status) }
    end
  end
end
