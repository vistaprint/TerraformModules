This repository contains generic [Terraform](https://www.terraform.io) modules. Using modules instead of ad-hoc configurations provides multiple benefits such as simplified configuration files, better testability and increased productivity overall.

The current available modules are:

* [API method](modules/api_method/README.md)
* [API variable-depth path](modules/api_path/README.md)
* [API deployment](modules/api_deployment/README.md)
* [Cloudwatch monitors for API gateway](modules/api_cloudwatch_monitors/README.md)
* [DynamoDB table](modules/dynamodb_table/README.md)
* [Lambdas](modules/lambda/README.md)

See [Terraform documentation](https://www.terraform.io/docs/modules/usage.html) for more information on how to use modules.

# Usage

To use modules within this repository set the source for the module to:

    source = "git::https://github.com/betabandido/terraformmodules.git//modules/MODULE_NAME"
    
where `MODULE_NAME` is the name of the module you wish to reference.

You can also target a specific branch or version tag by appending `?ref=` followed by either a tag name or branch name. For example:

    source = "git::https://github.com/betabandido/terraformmodules.git?ref=v0.0.4//modules/MODULE_NAME"

## Example

The following example uses the module `dynamodb_table` to create two DynamoDB tables (`Table1` and `Table2`). The first table uses default values for its capacity, while the second one uses the provided values.

```
module "aws_dynamodb_tables" {
  source = "git::https://github.com/betabandido/terraformmodules.git//modules/dynamodb_table"
  table_info = [
    {
      name = "Table1"
    },
    {
      name = "Table2"
      read_capacity = 2
      write_capacity = 2
    }
}
```

# Testing

To test all the modules, run the following command from the root directory:

    rake preflight

In order to run this command it is necessary to have valid AWS credentials in place. Multiple options are possible:

* Create a `terraform.tfvars` file within each folder containing a module test (these files should NOT be added to version control).
* Use access keys and region environment variables:
  * AWS_ACCESS_KEY_ID
  * AWS_SECRET_ACCESS_KEY
  * AWS_REGION
* Use profile and region environment variables:
  * AWS_PROFILE
  * AWS_REGION
* Set the profile and region fields in `config/config.yml` (see [Configuration File section](#configuration-file))

All the resources created in AWS will use a prefix to avoid name collisions. The default prefix is composed of the hostname and the current date and time (e.g., `HOSTNAME_1701021830_` for an execution that takes place on January 2nd 2017 at 6:30pm).

# Configuration File

The file `config/template-config.yml` contains a template for the configuration file. Copy this file to `config/config.yml` and configure it as required. Currently, this file follows the next structure:

```yaml
terraform-version: 0.9.8
aws:
  profile: A_PROFILE
  region: A_REGION
```

# Adding a New Module

The code for each module is located under the `modules` folder. Typically a module is composed of multiple files:

* `main.tf` contains the module's code
* `variables.tf` contains the input variables to the module
* `output.tf` contains the module's output variables (optional)

Tests for each module are located under the `test` folder. Tests typically perform three steps:

1. Creating a sample infrastructure in AWS
2. Testing the correctness of the infrastructure
3. Destroying the infrastructure

In addition to testing purposes, tests are intended to serve as a way of documenting the modules. So, ideally tests should be minimal, but meaningful.

## Test Components

A test should at least contain two files:

* `main.tf` creates an instance of the module under test, and sets up every other bit of necessary infrastructure
* `rakefile.rb` is the rake file responsible of conducting the test to the module.

A minimal rake file to create and destroy the infrastructure looks like:

```ruby
namespace 'module_name' do
  load '../../build/tasks.rake'
end
```

where `module_name` is the name of the module under test.

**IMPORTANT:** the name of the Terraform module should match the name of the namespace in the rake file, as well as the name of the subfolder in the `test` folder. Otherwise, the build scripts that orchestrate the testing process for all the modules will fail.

In addition to creating and destroying the infrastructure related to the module under test, it is recommended to test whether the infrastructure was correctly created. To do so, add a `validate` task to the rake file, and conduct the necessary tests.

In some cases it might also be necessary to do some preparation before the infrastructure is created (e.g., zipping the code of a lambda method). Use the `prepare` task to do so.

The following example shows the usage of both tasks:

```ruby
namespace 'module_name' do
  load '../../build/tasks.rake'

  module ModuleNameTest
    def self.fetch(api_url, cmd, name)
      url = "#{api_url}/#{cmd}/#{name}"
      puts("Fetching #{url}")
      Net::HTTP.get_response(URI(url))
    end
  end
  
  task :prepare, [:prefix] do |t, args|
    Zip::File.open('lambda.zip', Zip::File::CREATE) do |zipfile|
      zipfile.add('lambda.py', 'lambda.py')
    end
  end

  task :validate, [:prefix] do |t, args|
    api_url = Command.run('terraform output api_url').tr("\r\n", "")

    if ModuleNameTest.fetch(api_url, 'hello', 'Steve').body != 'Hello Steve'
      raise 'Error while querying the API'
    end
  end
end
```

Both tasks receive a `prefix` parameter that contains the prefix to be used to create all the resources in AWS. In the previous example the prefix is not used. But, it might be necessary to use if, for instance, the test uses the Ruby AWS SDK to directly inspect the created resources.

Helper methods should be placed into a module to avoid name collisions with methods from other rake files. The naming convention is to use the name of the module (in PascalCase) with the postfix `Test` (e.g., `ModuleNameTest` for a module called `module_name`).
