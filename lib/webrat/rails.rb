module Webrat
  class RailsSession < Session #:nodoc:

    def initialize(integration_session)
      super()
      @integration_session = integration_session
    end

    def doc_root
      File.expand_path(File.join(RAILS_ROOT, 'public'))
    end

    def saved_page_dir
      File.expand_path(File.join(RAILS_ROOT, "tmp"))
    end

    def get(url, data, headers = nil)
      do_request(:get, url, data, headers)
    end

    def post(url, data, headers = nil)
      do_request(:post, url, data, headers)
    end

    def put(url, data, headers = nil)
      do_request(:put, url, data, headers)
    end

    def delete(url, data, headers = nil)
      do_request(:delete, url, data, headers)
    end

    def response_body
      response.body
    end

    def response_code
      response.code.to_i
    end

  protected

    def do_request(http_method, url, data, headers) #:nodoc:
      update_protocol(url)
      @integration_session.send(http_method, remove_protocol(url), data, headers)
      @integration_session.follow_redirect_with_headers(headers) while Webrat.configuration.follow_redirects && @integration_session.internal_redirect?
      @integration_session.status
    end

    def remove_protocol(href) #:nodoc:
      if href =~ %r{^https?://www.example.com(/.*)}
        $LAST_MATCH_INFO.captures.first
      else
        href
      end
    end

    def update_protocol(href) #:nodoc:
      if href =~ /^https:/
        @integration_session.https!(true)
      elsif href =~ /^http:/
        @integration_session.https!(false)
      end
    end

    def response #:nodoc:
      @integration_session.response
    end
  end
end

module ActionController
  module Integration
    class Session #:nodoc:
      def internal_redirect?
        redirect? && response.redirect_url_match?(host)
      end

      def respond_to?(name)
        super || webrat_session.respond_to?(name)
      end

      def method_missing(name, *args, &block)
        if webrat_session.respond_to?(name)
          webrat_session.send(name, *args, &block)
        else
          super
        end
      end

      def follow_redirect_with_headers(h = {})
        raise "not a redirect! #{@status} #{@status_message}" unless redirect?
        h['HTTP_REFERER'] = current_url if current_url

        get(interpret_uri(headers["location"].first), {}, h)
        status
      end


    protected

      def webrat_session
        @webrat_session ||= Webrat::RailsSession.new(self)
      end

    end
  end
end
