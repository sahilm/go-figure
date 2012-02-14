module GoFigure

  class GoConfig
    attr_accessor :original_md5, :xml
    attr_reader   :original_xml

    def initialize(options = {})
      @original_md5 = options[:md5]
      @original_xml = options[:xml]
    end

  end

  class GoConfigEndpoint

    DEFAULT_OPTIONS = {
      :host => 'localhost',
      :port => 8153
    }

    attr_accessor *DEFAULT_OPTIONS.keys
    attr_accessor :http_fetcher

    def initialize(options)
      DEFAULT_OPTIONS.each do |k, v|
        self.send("#{k}=", options[k] || v)
      end
    end

    def get
      response = http_fetcher.get(config_xml_url)
      if response.status == 200
        GoConfig.new(:md5 => response['X-CRUISE-CONFIG-MD5'], :xml => response.body)
      end
    end

    def post(go_config)
      http_fetcher.post(config_xml_url, :xmlFile => go_config.xml, :md5 => go_config.original_md5)
    end

    def http_fetcher
      @http_fetcher || HttpFetcher.new
    end

    private
    def config_xml_url
      "http://#{host}:#{port}/go/api/admin/config.xml"
    end

  end

end
