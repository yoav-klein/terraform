
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.60"
        }
        datadog = {
            source = "DataDog/datadog"
        } 
    }
}

provider "datadog" {
    api_url = "https://api.us5.datadoghq.com/"

}
