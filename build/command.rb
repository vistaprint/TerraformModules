require 'open3'

module Command
  def self.run(cmd, directory = Dir.pwd)
    output = []

    Open3.popen2e(cmd, chdir: directory) do |_, stdout, thread|
      while line = stdout.gets
        output << line
        puts(line)
      end

      raise "Error running command #{cmd}" unless thread.value.success?
    end

    output.join('')
  end
end
