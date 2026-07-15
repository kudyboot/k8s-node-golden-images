terraform {
    backend "local" {
        path = "/opt/terraform/states/moj-projekt.tfstate"
    }
}