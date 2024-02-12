
data "aws_caller_identity" "current" {}

data "template_file" "pod_template" {
    template = "${file("${path.root}/templates/pod.yaml.template")}"
    vars = {
        account_id = data.aws_caller_identity.current.account_id
    }
}

resource "local_file" "pod" {
    filename = "${path.root}/pod.yaml"
    content = data.template_file.pod_template.rendered
}
