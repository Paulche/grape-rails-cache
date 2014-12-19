require "grape/rails/cache/version"

module Grape
  module Rails
    module Cache
      extend ActiveSupport::Concern

      included do
        HTTP_IF_NONE_MATCH     = 'HTTP_IF_NONE_MATCH'.freeze 

        helpers do
          def cache(object)
            if fresh?(object)
              error!("Not Modified", 304)
              
              header "ETag", etag
            else
              result = yield

              header "ETag", etag(object)
              header 'Cache-Control', 'public, max-age=1, must-revalidate'

              result
            end
          end

          def fresh?(object)
            if request_etag = if_none_match
              request_etag == etag(object)
            else
              false
            end
          end

          def etag(object)
            Digest::MD5.hexdigest(object.cache_key)
          end

          def if_none_match
            env[HTTP_IF_NONE_MATCH]
          end
        end
      end
    end
  end
end
