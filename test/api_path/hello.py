def say_hello(event, context):
    return {'Result': 'Hello {}'.format(event['name'])}
