
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.50"
        }
    }
}


resource "null_resource" "update_server" {
    triggers = {
        server   = aws_instance.this.id # when the server changes
        file = filesha1("fileset/one")
        dir  = sha1(join("", [for f in fileset("${path.root}", "fileset/changes/*"): filesha1(f)]))
    }

    provisioner "local-exec" {
        command = "date > last_modified"
    }
   
}


