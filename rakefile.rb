require 'socket'
require 'yaml'

require 'TerraformDevKit'

require_relative 'scripts/module_test'

TDK = TerraformDevKit

ROOT_PATH = File.dirname(File.expand_path(__FILE__))
BIN_PATH = File.join(ROOT_PATH, 'bin')

# Ensure terraform is in the PATH
ENV['PATH'] = TDK::OS.join_env_path(
  TDK::OS.convert_to_local_path(BIN_PATH),
  ENV['PATH']
)

HOSTNAME = Socket.gethostname
DATE = Time.new.strftime('%y%m%d%H%M%S')
DEFAULT_PREFIX = "TM_#{HOSTNAME}_#{DATE}_".freeze

TDK::Configuration.init('config/config.yml')

task default: [:preflight]

def run_task(task_name)
  ModuleTestRepository.each do |m|
    m.run_task(task_name)
  end
end

task :prepare do
  TDK::TerraformInstaller.install_local(
    TDK::Configuration.get('terraform-version'),
    directory: BIN_PATH
  )
end

desc 'Runs all the tests'
task :preflight => :prepare do
  run_task('preflight')
end

desc 'Destroy any remaining infrastructure'
task :destroy => :prepare do
  run_task('destroy')
end

desc 'Cleans up the project (after destroying infrastructure)'
task :clean => :prepare do
  run_task('clean')
end
