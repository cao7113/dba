module Dba::Util
  module_function

  def is_url?(url)
    url =~ %r(.+://.+)
  end
end
