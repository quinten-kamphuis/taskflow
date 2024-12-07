defmodule TaskflowWeb.ErrorJSONTest do
  use TaskflowWeb.ConnCase, async: true

  test "renders 404" do
    assert TaskflowWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert TaskflowWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
