class RubyEnv
  def self.bundler?(project_path)
    gem_exists?("bundler") && File.exists?("#{project_path}/Gemfile")
  end

  def self.gem_exists?(gem)
    if Gem::Specification.respond_to?(:find_by_name)
      Gem::Specification.find_by_name(gem)
    else
      # older depricated method
      Gem.available?(gem)
    end
  rescue Gem::LoadError
    false
  end

  def self.ruby_command(project_path, opts = {})
    ruby_interpreter = opts[:ruby_interpreter] || "ruby"

    if opts[:script] && File.exists?("#{project_path}/#{opts[:script]}")
      command = opts[:script]
    elsif opts[:bin]
      command = opts[:bin]
    else
      command = nil
    end

    if bundler?(project_path)
      "#{rvm_prefix(project_path)} #{ruby_interpreter} -S bundle exec #{command}".strip
    else
      "#{rvm_prefix(project_path)} #{ruby_interpreter} -S #{command}".strip
    end
  end

  def self.rvm_prefix(project_path)
    if rvm?
      rvmrc_path = File.join project_path, ".rvmrc"
      if File.exists?(rvmrc_path)
        File.read(rvmrc_path).to_s.strip + " exec"
      end
    end
  end

  def self.rvm?
    system("rvm info") != nil
  end
end
