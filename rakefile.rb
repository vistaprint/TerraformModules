require 'socket'
require 'yaml'

require 'TerraformDevKit'

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

MODULES_TO_TEST = Rake::FileList.new('test/*')

TDK::Configuration.init('config/config.yml')

task default: [:preflight]

def run_task_on_single_module(module_path, task_name)
  puts("=== Loading rakefile for #{module_path} ===")
  load 'rakefile.rb'
  namespace = File.basename(Dir.pwd)
  begin
    Rake::Task["#{namespace}:#{task_name}"].invoke(DEFAULT_PREFIX)
  rescue RuntimeError => e
    puts e.message
    puts e.backtrace.join("\n")
    Rake::Task["#{namespace}:clean"].invoke(DEFAULT_PREFIX)
    raise "Error testing module (#{module_path})"
  end
end

def run_task(task_name)
  TDK::TerraformInstaller.install_local(
    TDK::Configuration.get('terraform-version'),
    directory: BIN_PATH
  )
  MODULES_TO_TEST.each do |module_path|
    Dir.chdir(module_path) do
      run_task_on_single_module(module_path, task_name)
    end
  end
end

desc 'Runs all the tests'
task :preflight do
  run_task('preflight')
end

desc 'Destroy any remaining infrastructure'
task :destroy do
  run_task('destroy')
end

desc 'Cleans up the project (after destroying infrastructure)'
task :clean do
  run_task('clean')
end
