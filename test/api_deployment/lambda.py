from datetime import datetime


def handler(event, context):
    return {'Result': datetime.now().isoformat()}
