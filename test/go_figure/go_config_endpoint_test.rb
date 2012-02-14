require 'test_helper'


module GoFigure
  class GoConfigEndpointTest < Test::Unit::TestCase

    def test_should_fetch_xml_config_on_localhost
      md5 = '7455edff001e2f262beb7c13f10ff7cb'
      fetcher = GoConfigEndpoint.new(:host => 'example.com', :port => 1234)
      fetcher.http_fetcher = fetcher_with_config_file('foo.xml', md5, 'example.com', 1234)

      config = fetcher.get
      assert_equal config_file('foo.xml'), config.original_xml
      assert_equal md5, config.original_md5
    end

    def test_should_post_back_new_config_xml_content_with_original_md5
      md5 = '7455edff001e2f262beb7c13f10ff7cb'
      fetcher = GoConfigEndpoint.new(:host => 'example.com', :port => 1234)
      fetcher.http_fetcher = fetcher_with_config_file('foo.xml', md5, 'example.com', 1234)

      config = fetcher.get
      config.xml = "<new xml content/>"

      fetcher.http_fetcher.register_content("OK",
                                          "http://example.com:1234/go/api/admin/config.xml",
                                          :post,
                                          :md5 => config.original_md5,
                                          :xmlFile => config.xml)
      fetcher.post(config)
      assert fetcher.http_fetcher.invoked?("http://example.com:1234/go/api/admin/config.xml",
                                          :post,
                                          :md5 => config.original_md5,
                                          :xmlFile => config.xml)

    end

    def fetcher_with_config_file(file_name, md5, host = 'localhost', port = 8153)
      fetcher = StubHttpFetcher.new
      fetcher.register_content(config_file(file_name), "http://#{host}:#{port}/go/api/admin/config.xml", :get, 'X-CRUISE-CONFIG-MD5' => md5)
      fetcher
    end


    def config_file(file_name)
      File.read("test/fixtures/#{file_name}")
    end

  end
end
