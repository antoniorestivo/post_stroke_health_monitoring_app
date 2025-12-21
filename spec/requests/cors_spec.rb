require "rails_helper"

RSpec.describe "CORS", type: :request do
  let(:allowed_origin) { ENV.fetch("ALLOWED_ORIGIN", "http://localhost:5173") }
  let(:disallowed_origin) { "https://evil.example.com" }

  shared_examples "does not allow CORS" do
    it "does not set CORS headers for disallowed origin" do
      headers = {
        "Origin" => disallowed_origin,
        "Access-Control-Request-Method" => "GET"
      }

      options "/api/users", headers: headers

      expect(response.headers["Access-Control-Allow-Origin"]).to be_nil
      expect(response.headers["Access-Control-Allow-Credentials"]).to be_nil
    end
  end

  describe "preflight OPTIONS request" do
    context "with allowed origin" do
      it "returns correct CORS headers" do
        headers = {
          "Origin" => allowed_origin,
          "Access-Control-Request-Method" => "GET",
          "Access-Control-Request-Headers" => "Content-Type, Authorization"
        }

        options "/api/users", headers: headers

        expect(response).to have_http_status(:no_content).or have_http_status(:ok)
        expect(response.headers["Access-Control-Allow-Origin"]).to eq(allowed_origin)
        expect(response.headers["Access-Control-Allow-Credentials"]).to eq("true").or be_nil
        expect(response.headers["Access-Control-Allow-Methods"]).to include("GET")
      end
    end

    context "with disallowed origin" do
      include_examples "does not allow CORS"
    end
  end

  describe "simple GET request" do
    context "with allowed origin" do
      it "sets CORS headers on normal request" do
        headers = { "Origin" => allowed_origin }

        get "/api/users/me", headers: headers

        expect(response.headers["Access-Control-Allow-Origin"]).to eq(allowed_origin)
        expect(response.headers["Vary"]).to include("Origin")
      end
    end

    context "with disallowed origin" do
      include_examples "does not allow CORS"
    end
  end
end