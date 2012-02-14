module GoFigure

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

    def get_config
      response = http_fetcher.get(config_xml_url)
      if response.status == 200
        return GoConfig.new(:md5 => response['X-CRUISE-CONFIG-MD5'], :xml => response.body)
      else
        raise "Could not fetch the go config file"
      end
    end

    def update_config(go_config)
      http_fetcher.post(config_xml_url, :xmlFile => go_config.xml_content, :md5 => go_config.original_md5)
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
