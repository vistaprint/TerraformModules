require 'aws-sdk'
Aws.use_bundled_cert!

class DynamoDB
  def initialize(credentials, region)
    @db_client = Aws::DynamoDB::Resource.new(
      credentials: credentials,
      region: region
    )
  end

  def get_item(table_name, key)
    table = @db_client.table(table_name)
    table.get_item(key: key)
  end

  def put_item(table_name, item)
    table = @db_client.table(table_name)
    table.put_item(item: item)
  end
end
