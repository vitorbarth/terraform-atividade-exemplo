provider "aws" {
  region = "us-east-1"
}

module "imagem" {
  source = "../modules/reducao-imagem"
  redutor_imagem_version = "v0.0.2"
}
