resource "cloudflare_queue" "test_queue" {
  account_id = "%s"
  queue_name = "%s"
}

resource "cloudflare_queue" "dlq1" {
  account_id = "%s"
  queue_name = "%s"
}

resource "cloudflare_queue" "dlq2" {
  account_id = "%s"
  queue_name = "%s"
}

resource "cloudflare_queue_consumer" "%s" {
  account_id        = "%s"
  queue_id          = cloudflare_queue.test_queue.id
  type              = "worker"
  script_name       = cloudflare_workers_script.worker_script.script_name
  dead_letter_queue = cloudflare_queue.dlq2.queue_name
}

resource "cloudflare_workers_script" "worker_script" {
  account_id  = "%s"
  script_name = "test-worker"
  metadata = {
    main_module = "main.js"
    bindings = [
      {
        type       = "queue"
        name       = "incoming"
        queue_name = cloudflare_queue.test_queue.queue_name
      }
    ]
  }
  files = [
    {
      name    = "main.js"
      content = <<-EOT
      export default {
        async queue(batch, env, ctx) {
          for (const message of batch.messages) {
            console.log('Received', message);
          }
        }
      }
      EOT
    }
  ]
  
}