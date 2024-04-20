require "test_helper"

class InterviewControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get interview_index_url
    assert_response :success
  end
end
