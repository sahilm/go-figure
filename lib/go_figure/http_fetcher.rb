require 'net/http'
require 'net/https'

module GoFigure
  class HttpFetcher

    def get(url, params = {})
      url = URI.parse(url)

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = url.scheme == 'https'

      res = http.start do |http|
        req = Net::HTTP::Get.new(url.path)
        http.request(req)
      end

      case res
      when Net::HTTPSuccess
        return res
      end
      res.error!
    end

    def post(url, params = {})
      url = URI.parse(url)

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = url.scheme == 'https'

      res = http.start do |http|
        req = Net::HTTP::Post.new(url.path)
        req.set_form_data(params) if params.any?
        http.request(req)
      end

      case res
      when Net::HTTPSuccess
        return res
      end
      res.error!
    end

  end
end
