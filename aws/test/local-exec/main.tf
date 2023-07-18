
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
        file = filesha1("fileset/one")
        dir  = sha1(join("", [for f in fileset("${path.root}", "fileset/changes/**"): filesha1(f)]))
    }

    provisioner "local-exec" {
        command = "date > last_modified"
    }
   
}


