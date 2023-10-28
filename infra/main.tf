terraform {
  required_providers {

    aws = { #como eu estou me conectando 
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {          #dados daquele provedor especifico
  region = var.regiao_aws #region da aws
}

resource "aws_instance" "app_server" {    #
  ami           = "ami-0efcece6bed30fd98" #id da imagem que que quero para minha instancia (nesse caso ubuntu)
  instance_type = var.instancia           #qual instancia que eu quero subir
  key_name      = var.chave               #Adicionando uma chave ssh para acessar a instancia, criada como par de chaves na aws

  tags = {
    #nome que podemos colocar na instancia
    Name = "Instancia Terraform"
  }
}

#adicionando um par de chaves na aws
resource "aws_key_pair" "acessoSSH" {
  key_name   = var.chave
  public_key = file("${var.chave}.pub") #recuperando a chave do meu sistema
}

#Saida do ip
output "IP_publico" {
  value = aws_instance.app_server.public_ip
}
