require 'test_helper'


module GoFigure
  class GoConfigEndpointTest < Test::Unit::TestCase

    def test_should_fetch_xml_config_on_localhost
      md5 = '7455edff001e2f262beb7c13f10ff7cb'
      endpoint = GoConfigEndpoint.new(:host => 'example.com', :port => 1234)
      endpoint.http_fetcher = fetcher_with_config_file('foo.xml', md5, config_endpoint)

      config = endpoint.get_config
      assert_equal config_file('foo.xml'), config.original_xml
      assert_equal md5, config.original_md5
    end

    def test_should_post_back_new_config_xml_content_with_original_md5
      md5 = '7455edff001e2f262beb7c13f10ff7cb'
      endpoint = GoConfigEndpoint.new(:host => 'example.com', :port => 1234)
      endpoint.http_fetcher = fetcher_with_config_file('foo.xml', md5, config_endpoint)

      config = endpoint.get_config
      config.set_pipeline("http://git.example.com/foo/bar.git", "my_rails_app")

      endpoint.http_fetcher.register_content("OK", config_endpoint, :post, :md5 => config.original_md5, :xmlFile => config.xml_content)

      endpoint.update_config(config)
      assert endpoint.http_fetcher.invoked?(config_endpoint, :post, :md5 => config.original_md5, :xmlFile => config.xml_content)
    end

    def config_endpoint
      "http://example.com:1234/go/api/admin/config.xml"
    end

    def fetcher_with_config_file(file_name, md5, url)
      endpoint = StubHttpFetcher.new
      endpoint.register_content(config_file(file_name), config_endpoint, :get, 'X-CRUISE-CONFIG-MD5' => md5)
      endpoint
    end

    def config_file(file_name)
      File.read("test/fixtures/#{file_name}")
    end

  end
end
