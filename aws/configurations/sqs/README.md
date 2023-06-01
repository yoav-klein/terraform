# Amazon SQS
---

In this configuration, we create a SQS queue.

A SQS queue is a message queue service that allows distributed system components to send
and receive messages to and from the queue.

In this configuration we create a Standard queue (as opposed to FIFO queue).

## Create the queue
Run the terrafom code to create the queue:
```
$ terraform apply -auto-approve
```

## Test

Let's run a small flow of sending a message, receiving it and deleting it:

### Send a message
```
$ aws sqs send-message --queue-url $(terraform output -raw url) --message-body "Hello mate"
< optionally send more messages >
```

### Receive the message(s)

Note that we configure our queue with the `delay_seconds` setting set to 30, so in the first 30
seconds the message is not visible.

Note that we

```
$ aws sqs receive-message --queue-url $(terraform output -raw url)
# message output
```

### Delete the message

In order to delete the message, we need the _ReceiptHandle__
```
$ handle=$(aws sqs receive-message --queue-url $(terraform output -raw url) | jq -r '.Messages[0].ReceiptHandle')
$ aws sqs delete-message --queue-url $(terraform output -raw url ) --receipt-handle $handle
```
