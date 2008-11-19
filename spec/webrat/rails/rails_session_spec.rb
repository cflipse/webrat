require File.expand_path(File.dirname(__FILE__) + '/helper')

describe Webrat::RailsSession do
  before :each do
    @integration_session = mock("integration_session")
    @integration_session.stub!(:internal_redirect?)
    @integration_session.stub!(:status)
  end

  it "should require a Rails Integration session to be initialized" do
    lambda {
      Webrat::RailsSession.new
    }.should raise_error
  end

  it "should delegate response_body to the session response body" do
    @integration_session.stub!(:response => mock("response", :body => "<html>"))
    Webrat::RailsSession.new(@integration_session).response_body.should == "<html>"
  end

  it "should delegate response_code to the session response code" do
    @integration_session.stub!(:response => mock("response", :code => "42"))
    Webrat::RailsSession.new(@integration_session).response_code.should == 42
  end

  it "should delegate get to the integration session" do
    @integration_session.should_receive(:get).with("url", "data", "headers")
    rails_session = Webrat::RailsSession.new(@integration_session)
    rails_session.get("url", "data", "headers")
  end

  it "should delegate post to the integration session" do
    @integration_session.should_receive(:post).with("url", "data", "headers")
    rails_session = Webrat::RailsSession.new(@integration_session)
    rails_session.post("url", "data", "headers")
  end

  it "should delegate put to the integration session" do
    @integration_session.should_receive(:put).with("url", "data", "headers")
    rails_session = Webrat::RailsSession.new(@integration_session)
    rails_session.put("url", "data", "headers")
  end

  it "should delegate delete to the integration session" do
    @integration_session.should_receive(:delete).with("url", "data", "headers")
    rails_session = Webrat::RailsSession.new(@integration_session)
    rails_session.delete("url", "data", "headers")
  end

  it "should follow internal redirects" do
    @integration_session.stub!(:get)
    @integration_session.stub!(:host)
    @integration_session.stub!(:status)

    @integration_session.should_receive(:internal_redirect?).twice.and_return(true, false)
    @integration_session.should_receive(:follow_redirect!)

    rails_session = Webrat::RailsSession.new(@integration_session)
    rails_session.get("url", "data", "headers")
  end

  it "should not follow external redirects" do
    @integration_session.stub!(:get)
    @integration_session.stub!(:host)
    @integration_session.stub!(:status)

    @integration_session.should_receive(:internal_redirect?).and_return(false)
    @integration_session.should_not_receive(:follow_redirect!)

    rails_session = Webrat::RailsSession.new(@integration_session)
    rails_session.get("url", "data", "headers")
  end

  context "the URL is a full path" do
    it "should just pass on the path" do
      @integration_session.stub!(:https!)
      @integration_session.should_receive(:get).with("/url", "data", "headers")
      rails_session = Webrat::RailsSession.new(@integration_session)
      rails_session.get("http://www.example.com/url", "data", "headers")
    end
  end

  context "the URL is https://" do
    it "should call #https! with true before the request and just pass on the path" do
      @integration_session.should_receive(:https!).with(true)
      @integration_session.should_receive(:get).with("/url", "data", "headers")
      rails_session = Webrat::RailsSession.new(@integration_session)
      rails_session.get("https://www.example.com/url", "data", "headers")
    end
  end

  context "the URL is http://" do
    it "should call #https! with true before the request" do
      @integration_session.stub!(:get)
      @integration_session.should_receive(:https!).with(false)
      rails_session = Webrat::RailsSession.new(@integration_session)
      rails_session.get("http://www.example.com/url", "data", "headers")
    end
  end

  it "should provide a saved_page_dir" do
    Webrat::RailsSession.new(@integration_session).should respond_to(:saved_page_dir)
  end

  it "should provide a doc_root" do
    Webrat::RailsSession.new(@integration_session).should respond_to(:doc_root)
  end

  describe ActionController::Integration::Session do
    before :each do
      @integration_session = ActionController::Integration::Session.new
      @integration_session.stub!(:response => mock("response"))
    end

    describe "internal_redirect?" do
      it "should return false if the response is not a redirect" do
        @integration_session.should_receive(:redirect?).and_return(false)
        @integration_session.internal_redirect?.should == false
      end

      it "should return false if the response was a redirect but the response location does not match the request host" do
        @integration_session.should_receive(:redirect?).and_return(true)
        @integration_session.response.should_receive(:redirect_url_match?).and_return(false)
        @integration_session.internal_redirect?.should == false
      end

      it "should return true if the response is a redirect and the response location matches the request host" do
        @integration_session.should_receive(:redirect?).and_return(true)
        @integration_session.response.should_receive(:redirect_url_match?).and_return(true)
        @integration_session.internal_redirect?.should == true
      end
    end
  end
end