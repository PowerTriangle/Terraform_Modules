terraform {
  required_version = ">= 1.6.0"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0, < 4.0.0"
    }
  }
}

resource "random_id" "suffix" {
  byte_length = 3
}

output "suffix" {
  value = random_id.suffix.hex
}
