terraform {
  cloud {
    organization = "org-POD4"

    workspaces {
      name = "wrkspc-POD4"
    }
  }

  required_version = ">= 1.0.0"
}
