require "./spec_helper"

struct MyModel < KemalRestApi::Model
  def create( args : Hash(String, String) )
    args ? 8 : nil
  end

  def read( id : Int )
    if id > 10
      nil
    else
      { "title": "Item #{rand(100)}", "num": "#{rand(100)}" }
    end
  end

  def update( id : Int, args : Hash(String, String) )
    if id > 10
      nil
    elsif id > 5
      1
    else
      0
    end
  end

  def delete( id : Int )
    if id > 10
      nil
    elsif id > 5
      1
    else
      0
    end
  end

  def list
    items = [] of Hash(String, String)
    3.times do
      items.push( { "title" => "Item #{rand(100)}", "num" => "#{rand(100)}" }.to_h )
    end
    items
  end
end

KemalRestApi::Resource.new MyModel.new, nil, singular: "item"

MSG_NOT_FOUND = "Not Found"
MSG_OK = "ok"

describe KemalRestApi do
  Spec.before_each do
    KemalRestApi.generate_routes!
  end

  context "success responses" do
    it "should create an item" do
      request = HTTP::Request.new "POST", "/items"
      response = call_request_on_app request
      response.status_code.should eq( 201 )
      response.headers["Content-Type"]?.should eq( "application/json" )
      json = JSON.parse response.body
      json["message"]?.should eq( MSG_OK )
      ( json["id"]?.to_s.size > 0 ).should eq( true )
    end

    it "should read an item" do
      request = HTTP::Request.new "GET", "/items/8"
      response = call_request_on_app request
      response.status_code.should eq( 200 )
      response.headers["Content-Type"]?.should eq( "application/json" )
      json = JSON.parse response.body
      ( json["title"]?.to_s.size > 0 ).should eq( true )
      ( json["num"]?.to_s.size > 0 ).should eq( true )
      ( json["invalid_key"]?.to_s.size > 0 ).should eq( false )
    end

    it "should update an item" do
      request = HTTP::Request.new "PUT", "/items/8"
      response = call_request_on_app request
      response.status_code.should eq( 200 )
      response.headers["Content-Type"]?.should eq( "application/json" )
      json = JSON.parse response.body
      json["message"]?.should eq( MSG_OK )
    end

    it "should delete an item" do
      request = HTTP::Request.new "DELETE", "/items/8"
      response = call_request_on_app request
      response.status_code.should eq( 200 )
      response.headers["Content-Type"]?.should eq( "application/json" )
      json = JSON.parse response.body
      json["message"]?.should eq( MSG_OK )
    end

    it "should list 3 items" do
      request = HTTP::Request.new "GET", "/items"
      response = call_request_on_app request
      response.status_code.should eq( 200 )
      response.headers["Content-Type"]?.should eq( "application/json" )
      json = JSON.parse response.body
      json.size.should eq( 3 )
    end
  end

  context "not_found responses" do
    it "should not read an item" do
      request = HTTP::Request.new "GET", "/items/12"
      response = call_request_on_app request
      response.status_code.should eq( 404 )
      response.headers["Content-Type"]?.should eq( "application/json" )
      json = JSON.parse response.body
      json["message"]?.should eq( MSG_NOT_FOUND )
    end

    it "should not update an item" do
      request = HTTP::Request.new "PUT", "/items/12"
      response = call_request_on_app request
      response.status_code.should eq( 404 )
      response.headers["Content-Type"]?.should eq( "application/json" )
      json = JSON.parse response.body
      json["message"]?.should eq( MSG_NOT_FOUND )
    end

    it "should not delete an item" do
      request = HTTP::Request.new "DELETE", "/items/12"
      response = call_request_on_app request
      response.status_code.should eq( 404 )
      response.headers["Content-Type"]?.should eq( "application/json" )
      json = JSON.parse response.body
      json["message"]?.should eq( MSG_NOT_FOUND )
    end
  end

  # context "with invalid responses" do
  #   it "should not delete an item" do
  #     request = HTTP::Request.new "DELETE", "/items/4"
  #     response = call_request_on_app request
  #     response.status_code.should eq( 400 )
  #     response.headers["Content-Type"]?.should eq( "application/json" )
  #     json = JSON.parse response.body
  #     json["message"]?.should eq( MSG_NOT_FOUND )
  #   end
  # end
end