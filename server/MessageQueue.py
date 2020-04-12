# represents a queue service (AWS SQS or RabbitMQ)
class MessageQueue:
    def __init__(self, messages):
        self.messages = messages