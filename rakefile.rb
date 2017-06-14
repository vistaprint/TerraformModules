require 'socket'
require 'yaml'

require_relative 'build/backup_state'
require_relative 'build/config'
require_relative 'build/terraform_installer'
require_relative 'build/os'

ROOT_PATH = File.dirname(__FILE__)
# Ensure terraform is in the PATH
ENV['PATH'] = OS.join_env_path(ROOT_PATH, ENV['PATH'])

HOSTNAME = Socket.gethostname
DATE = Time.new.strftime('%y%m%d%H%M%S')
DEFAULT_PREFIX = "#{HOSTNAME}_#{DATE}_".freeze

MODULES_TO_TEST = Rake::FileList.new('test/*')

Configuration.init('config/config.yml')

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
    BackupState.backup(DEFAULT_PREFIX)
    raise "Error testing module (#{module_path})"
  end
end

def run_task(task_name)
  TerraformInstaller.install_local(Configuration.get('terraform-version'))
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
