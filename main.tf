terraform {
  required_providers {

    aws = { #como eu estou me conectando 
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {       #dados daquele provedor especifico
  region = "us-west-2" #region da aws
}

resource "aws_instance" "app_server" {    #
  ami           = "ami-0efcece6bed30fd98" #id da imagem que que quero para minha instancia (nesse caso ubuntu)
  instance_type = "t2.micro"              #qual instancia que eu quero subir
  key_name      = "iac-alura"

  tags = {
    #nome que podemos colocar na instancia
    Name = "Instancia Terraform"
  }
}
