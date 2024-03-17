# tech-challenge-fiap-lambda-auth

Aplicação responsável pela gestão da infra da lambda authorizer

[Validação local](#validação-local)

## Validação Local

Etapas necessárias antes da criação do PR:

Pré requisitos:

    - Instale e configure o AWS CLI (https://docs.aws.amazon.com/cli/latest/reference/configure/)(necessário para a execução do comando plan)

    - Instale o Terraform (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

Execute os seguintes comandos para validarmos o terraform (precisa estar na mesma pasta do main.tf):

```bash
terraform init -> comando responsável por inicializar os módulos do seu terraform

terraform validate -> comando responsável por validar as configurações do seu terraform

terraform plan -> comando responsável por validar os recursos que vão ser provisionados 
```