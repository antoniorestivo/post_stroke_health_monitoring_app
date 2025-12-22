RSpec.shared_context "json helpers" do
  def json_body
    body = response.body
    while body.is_a?(String) do
      body = JSON.parse(body)
    end
    body
  end

  def json_data
    json_body["data"]
  end

  def json_errors
    json_body["errors"]
  end
end

RSpec.configure do |config|
  config.include_context "json helpers", type: :request
  config.include_context "json helpers", type: :controller
end