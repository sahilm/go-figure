require 'net/http'
require 'net/https'

module UserImport
  class HttpFetcher

    def fetch(url, user, pass)
      url = URI.parse(url)

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = url.scheme == 'https'

      res = http.start do |http|
        req = Net::HTTP::Get.new(url.path)
        req.basic_auth user, pass
        http.request(req)
      end

      case res
      when Net::HTTPSuccess
        return res.body
      end
      res.error!
    end
  end
end

