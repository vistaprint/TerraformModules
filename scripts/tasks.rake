require 'fileutils'
require 'TerraformDevKit'

TDK = TerraformDevKit unless defined? TDK

def add_aws_variables(cmd)
  aws_config = TDK::AwsConfig.new(TDK::Configuration.get('aws'))
  profile = aws_config.profile
  region = aws_config.region
  cmd += " -var profile=#{profile}" unless profile.nil?
  cmd += " -var region=#{region}" unless region.nil?
  cmd
end

task :init do |_, args|
  namespace = File.basename(Dir.pwd)
  prepare_task = "#{namespace}:prepare"
  Rake::Task[prepare_task].invoke(args.prefix) if Rake::Task.task_defined?(prepare_task)
  TDK::Command.run('terraform init')
end

desc 'Creates the infrastructure'
task :apply, [:prefix] => :init do |_, args|
  cmd = "terraform apply -var prefix=#{args.prefix}"
  TDK::Command.run(add_aws_variables(cmd))
end

desc 'Runs preflight'
task :preflight, [:prefix, :teardown] => :apply do |_, args|
  args.with_defaults(teardown: 'true')

  namespace = File.basename(Dir.pwd)
  validate_task = "#{namespace}:validate"
  Rake::Task[validate_task].invoke(args.prefix) if Rake::Task.task_defined?(validate_task)

  if args.teardown == 'true'
    destroy_task = "#{namespace}:destroy"
    Rake::Task[destroy_task].invoke(args.prefix)
  end
end

desc 'Destroys the infrastructure'
task :destroy, [:prefix] => :init do |_, args|
  cmd = "terraform destroy -force -var prefix=#{args.prefix}"
  TDK::Command.run(add_aws_variables(cmd))
end

desc 'Cleans up the test folder (after destroying the infrastructure)'
task :clean, [:prefix] => :destroy do
  # The directories containing terraform information ('.terraform') cannot
  # be deleted. They contain symlinks to the real module directories and some
  # versions of Ruby apparently do not support just deleting the symlink
  # (without deleting the directory it points to).
  files = Dir.glob('*.zip') \
    + Dir.glob('*.tfstate') \
    + Dir.glob('*.tfstate.backup')
  puts "Deleting #{files}"
  FileUtils.rm_rf(files, secure: true)
end
