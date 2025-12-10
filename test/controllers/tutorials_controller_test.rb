require "test_helper"

class TutorialsControllerTest < ActionDispatch::IntegrationTest
  test "should get install" do
    get tutorials_install_url
    assert_response :success
  end
end
