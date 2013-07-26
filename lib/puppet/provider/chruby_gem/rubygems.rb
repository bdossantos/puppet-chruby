require 'puppet/util/execution'

Puppet::Type.type(:chruby_gem).provide(:rubygems) do
  include Puppet::Util::Execution
  desc ""

  def path
    [
      "#{Facter[:boxen_home].value}/homebrew/bin",
      "$PATH"
    ].join(':')
  end

  def chruby_gem(command)
    full_command = [
      "sudo -u #{Facter[:boxen_user].value}",
      "PATH=#{path}",
      "PREFIX=#{@resource[:chruby_root]}",
      "#{@resource[:chruby_root]}/bin/chruby-exec",
      "#{@resource[:chruby_version]} -- \"gem #{command}\"",
    ].join(" ")

    output = `#{full_command}`

    [output, $?]
  end

  def create
    chruby_gem "install '#{@resource[:gem]}' -v '#{@resource[:version]}'"
  end

  def destroy
    chruby_gem "uninstall '#{@resource[:gem]}' -v '#{@resource[:version]}'"
  end

  def exists?
    gem_dir = chruby_gem("env gemdir").first.strip
    requirement = Gem::Requirement.new(@resource[:version])

    Dir["#{gem_dir}/gems/#{@resource[:gem]}-*"].each do |path|
      gem_with_version = File.basename(path)

      # skip gems that start with @resource[:gem] to avoid false positives
      # eg. heroku / heroku-api
      next unless gem_with_version =~ /^#{@resource[:gem]}-\d/

      version = gem_with_version.gsub(/^#{@resource[:gem]}-/, '')
      return true if requirement.satisfied_by? Gem::Version.new(version)
    end

    false
  end
end
