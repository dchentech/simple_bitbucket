module Bitbucket
  VERBOSE = false

  def create_and_sync path, name = nil
    name = path.split('/')[-1].sub(/\.git$/i, '') if name.nil?
    curl_command "/repositories", {:method => :post, :params => {:name => name} }

    FileUtils.chdir path
    `git remote add origin git@bitbucket.org:#{Username}/#{name}.git`
    `git push origin master`
  end

  def list
    str = curl_command("/user/repositories")
    JSON.parse(str)
  end

  def curl_command path, opts = {}
    method = opts.delete(:method) || :get

    addition = case method.to_sym
    when :get
    when :post
      d = opts[:params].map {|k, v| "#{k}=#{v}" }.join("&")
      "-k -X POST -d #{d}"
    end
    vebose_str = VERBOSE ? '-v' : ''
    `curl #{addition} --user #{Email}:#{Password} https://api.bitbucket.org/1.0#{path} #{vebose_str}`
  end
  module_function :create_and_sync, :list, :curl_command
end
