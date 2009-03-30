require 'rubygems'

gem 'why-hpricot'
gem 'rest-client'

require 'hpricot'
require 'rest_client'

require 'time'
require 'cgi'
require 'base64'
require 'openssl'

require 'zama-sdb/results'
require 'zama-sdb/model_enum'
require 'zama-sdb/model'

module Zama

  module SDB

    def self.setup(opts)
      @@opts = {
        :Version => "2007-11-07",
        :SignatureVersion => "1",
        :url => "http://sdb.amazonaws.com"
      }.merge(opts)
    end

    def self.opts; @@opts; end;

  end
  

end
