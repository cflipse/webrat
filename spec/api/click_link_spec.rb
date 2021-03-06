require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "click_link" do
  before do
    @session = Webrat::TestSession.new
  end

  it "should click links with ampertands" do
    @session.response_body = <<-EOS
      <a href="/page">Save &amp; go back</a>
    EOS
    @session.should_receive(:get).with("/page", {})
    @session.click_link "Save & go back"
  end
  
  it "should use get by default" do
    @session.response_body = <<-EOS
      <a href="/page">Link text</a>
    EOS
    @session.should_receive(:get).with("/page", {})
    @session.click_link "Link text"
  end

  it "should click get links" do
    @session.response_body = <<-EOS
      <a href="/page">Link text</a>
    EOS
    @session.should_receive(:get).with("/page", {})
    @session.click_link "Link text", :method => :get
  end
  
  it "should click link on substring" do
    @session.response_body = <<-EOS
      <a href="/page">Link text</a>
    EOS
    @session.should_receive(:get).with("/page", {})
    @session.clicks_link "ink tex", :method => :get
  end
  
  it "should click delete links" do
    @session.response_body = <<-EOS
      <a href="/page">Link text</a>
    EOS
    @session.should_receive(:delete).with("/page", {})
    @session.click_link "Link text", :method => :delete
  end
  
  
  it "should click post links" do
    @session.response_body = <<-EOS
      <a href="/page">Link text</a>
    EOS
    @session.should_receive(:post).with("/page", {})
    @session.click_link "Link text", :method => :post
  end
  
  it "should click put links" do
    @session.response_body = <<-EOS
      <a href="/page">Link text</a>
    EOS
    @session.should_receive(:put).with("/page", {})
    @session.click_link "Link text", :method => :put
  end
  
  it "should click links by regexp" do
    @session.response_body = <<-EOS
      <a href="/page">Link text</a>
    EOS
    @session.should_receive(:get).with("/page", {})
    @session.click_link /link [a-z]/i
  end
  
  it "should click links by id" do 
    @session.response_body = <<-EOS
      <a id="link_text_link" href="/page">Link text</a>
    EOS
    @session.should_receive(:get).with("/page", {})
    @session.clicks_link "link_text_link"
  end
  
  it "should click links by id regexp" do 
    @session.response_body = <<-EOS
      <a id="link_text_link" href="/page">Link text</a>
    EOS
    @session.should_receive(:get).with("/page", {})
    @session.clicks_link /_text_/
  end
  
  it "should click rails javascript links with authenticity tokens" do
    @session.response_body = <<-EOS
      <a href="/posts" onclick="var f = document.createElement('form');
        f.style.display = 'none';
        this.parentNode.appendChild(f);
        f.method = 'POST';
        f.action = this.href;
        var s = document.createElement('input');
        s.setAttribute('type', 'hidden');
        s.setAttribute('name', 'authenticity_token');
        s.setAttribute('value', 'aa79cb354597a60a3786e7e291ed4f74d77d3a62');
        f.appendChild(s);
        f.submit();
        return false;">Posts</a>
    EOS
    @session.should_receive(:post).with("/posts", "authenticity_token" => "aa79cb354597a60a3786e7e291ed4f74d77d3a62")
    @session.click_link "Posts"
  end
  
  it "should click rails javascript delete links" do
    @session.response_body = <<-EOS
      <a href="/posts/1" onclick="var f = document.createElement('form');
        f.style.display = 'none';
        this.parentNode.appendChild(f);
        f.method = 'POST';
        f.action = this.href;
        var m = document.createElement('input');
        m.setAttribute('type', 'hidden');
        m.setAttribute('name', '_method');
        m.setAttribute('value', 'delete');
        f.appendChild(m);
        f.submit();
        return false;">Delete</a>
    EOS
    @session.should_receive(:delete).with("/posts/1", {})
    @session.click_link "Delete"
  end
  
  it "should click rails javascript post links" do
    @session.response_body = <<-EOS
      <a href="/posts" onclick="var f = document.createElement('form');
        f.style.display = 'none';
        this.parentNode.appendChild(f);
        f.method = 'POST';
        f.action = this.href;
        f.submit();
        return false;">Posts</a>
    EOS
    @session.should_receive(:post).with("/posts", {})
    @session.click_link "Posts"
  end
  
  it "should click rails javascript post links without javascript" do
    @session.response_body = <<-EOS
      <a href="/posts" onclick="var f = document.createElement('form');
        f.style.display = 'none';
        this.parentNode.appendChild(f);
        f.method = 'POST';
        f.action = this.href;
        f.submit();
        return false;">Posts</a>
    EOS
    @session.should_receive(:get).with("/posts", {})
    @session.click_link "Posts", :javascript => false
  end
  
  it "should click rails javascript put links" do
    @session.response_body = <<-EOS
      <a href="/posts" onclick="var f = document.createElement('form');
        f.style.display = 'none';
        this.parentNode.appendChild(f);
        f.method = 'POST';
        f.action = this.href;
        var m = document.createElement('input');
        m.setAttribute('type', 'hidden');
        m.setAttribute('name', '_method');
        m.setAttribute('value', 'put');
        f.appendChild(m);
        f.submit();
        return false;">Put</a></h2>
    EOS
    @session.should_receive(:put).with("/posts", {})
    @session.click_link "Put"
  end
  
  it "should fail if the javascript link doesn't have a value for the _method input" do
    @session.response_body = <<-EOS
      <a href="/posts/1" onclick="var f = document.createElement('form');
        f.style.display = 'none';
        this.parentNode.appendChild(f);
        f.method = 'POST';
        f.action = this.href;
        var m = document.createElement('input');
        m.setAttribute('type', 'hidden');
        m.setAttribute('name', '_method');
        f.appendChild(m);
        f.submit();
        return false;">Link</a>
    EOS
    
    lambda {
      @session.click_link "Link"
    }.should raise_error
  end
  
  it "should assert valid response" do
    @session.response_body = <<-EOS
      <a href="/page">Link text</a>
    EOS
    @session.response_code = 501
    lambda { @session.click_link "Link text" }.should raise_error
  end
  
  [200, 300, 400, 499].each do |status|
    it "should consider the #{status} status code as success" do
      @session.response_body = <<-EOS
        <a href="/page">Link text</a>
      EOS
      @session.response_code = status
      lambda { @session.click_link "Link text" }.should_not raise_error
    end
  end
  
  it "should fail is the link doesn't exist" do
    @session.response_body = <<-EOS
      <a href="/page">Link text</a>
    EOS
    
    lambda {
      @session.click_link "Missing link"
    }.should raise_error
  end
  
  it "should not be case sensitive" do
    @session.response_body = <<-EOS
      <a href="/page">Link text</a>
    EOS
    @session.should_receive(:get).with("/page", {})
    @session.click_link "LINK TEXT"
  end
  
  it "should match link substrings" do
    @session.response_body = <<-EOS
      <a href="/page">This is some cool link text, isn't it?</a>
    EOS
    @session.should_receive(:get).with("/page", {})
    @session.click_link "Link text"
  end
  
  it "should work with elements in the link" do
    @session.response_body = <<-EOS
      <a href="/page"><span>Link text</span></a>
    EOS
    @session.should_receive(:get).with("/page", {})
    @session.click_link "Link text"
  end
  
  it "should match the first matching link" do
    @session.response_body = <<-EOS
      <a href="/page1">Link text</a>
      <a href="/page2">Link text</a>
    EOS
    @session.should_receive(:get).with("/page1", {})
    @session.click_link "Link text"
  end
  
  it "should choose the shortest link text match" do
    @session.response_body = <<-EOS
    <a href="/page1">Linkerama</a>
    <a href="/page2">Link</a>
    EOS
    
    @session.should_receive(:get).with("/page2", {})
    @session.click_link "Link"
  end
  
  it "should treat non-breaking spaces as spaces" do
    @session.response_body = <<-EOS
    <a href="/page1">This&nbsp;is&nbsp;a&nbsp;link</a>
    EOS
    
    @session.should_receive(:get).with("/page1", {})
    @session.click_link "This is a link"
  end
  
  it "should not match on non-text contents" do
    pending "needs fix"
    @session.response_body = <<-EOS
    <a href="/page1"><span class="location">My house</span></a>
    <a href="/page2">Location</a>
    EOS
    
    @session.should_receive(:get).with("/page2", {})
    @session.click_link "Location"
  end
  
  it "should click link within a selector" do
    @session.response_body = <<-EOS
    <a href="/page1">Link</a>
    <div id="container">
      <a href="/page2">Link</a>
    </div>
    EOS
    
    @session.should_receive(:get).with("/page2", {})
    @session.click_link_within "#container", "Link"
  end

  it "should not make request when link is local anchor" do
    @session.response_body = <<-EOS
      <a href="#section-1">Jump to Section 1</a>
    EOS
    # Don't know why @session.should_receive(:get).never doesn't work here
    @session.should_receive(:send).with('get_via_redirect', '#section-1', {}).never
    @session.click_link "Jump to Section 1"
  end

  it "should follow relative links" do
    @session.stub!(:current_url).and_return("/page")
    @session.response_body = <<-EOS
      <a href="sub">Jump to sub page</a>
    EOS
    @session.should_receive(:get).with("/page/sub", {})
    @session.click_link "Jump to sub page"
  end
  
  it "should follow fully qualified local links" do
    @session.stub!(:current_url).and_return("/page")
    @session.response_body = <<-EOS
      <a href="http://subdomain.example.com/page/sub">Jump to sub page</a>
    EOS
    @session.should_receive(:get).with("http://subdomain.example.com/page/sub", {})
    @session.click_link "Jump to sub page"
  end
  
  it "should follow fully qualified local links to example.com" do
    @session.response_body = <<-EOS
      <a href="http://www.example.com/page/sub">Jump to sub page</a>
    EOS
    @session.should_receive(:get).with("http://www.example.com/page/sub", {})
    @session.click_link "Jump to sub page"
  end

  it "should follow query parameters" do
    @session.stub!(:current_url).and_return("/page")
    @session.response_body = <<-EOS
      <a href="?foo=bar">Jump to foo bar</a>
    EOS
    @session.should_receive(:get).with("/page?foo=bar", {})
    @session.click_link "Jump to foo bar"
  end
end
