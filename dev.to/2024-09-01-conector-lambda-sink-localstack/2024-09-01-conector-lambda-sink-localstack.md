---
title: Conector Lambda Sink do Kafka com Localstack
published: false
description: 
tags: 
# cover_image: https://direct_url_to_image.jpg
# Use a ratio of 100:42 for best results.
# published_at: 2024-09-01 21:51 +0000
---

## Introdução
Ao trabalhar em projetos corporativos é comum movermos informações de um lugar para outro através do Kafka utilizando conectores source e sink. Os conectores source são utilizados para enviar informações aos tópicos Kafka, já os **conectores sink**, enviam para uma fonte externa como um banco de dados, ferramenta de logs ou um recursos na AWS como uma lambda. Hoje vamos falar sobre o conector sink, especificamente o conector Lambda Sink usando o [Localstack](https://www.localstack.cloud/) para "emularmos" o serviço de uma Lambda.

## Pré requisitos
- Docker 
- Docker compose
- [aws-cli](https://docs.aws.amazon.com/pt_br/cli/latest/userguide/getting-started-install.html)
- curl ou alguma ferramenta semelhante ao Insomnia.
- Configurar `~/.aws/config` da seguinte forma:
```bash
[default]
region = us-east-1
output = json
```

## Sobre o projeto
O objetivo deste projeto é trazer a experiência do desenvolvimento de um ambiente corporativo de forma acessível e sem gastos ou burocracia no uso da Cloud.

![Fluxograma do conector Lambda Sink. Producer enviando mensagem para um tópico Kafka que dispara um evento para o conector que envia a mensagem para uma Lambda](./fluxo-conector-lambda-sink.drawio.svg)


Vamos utilizar um docker-composer contendo o serviço Kafka e o Localstack. No serviço Kafka vamos utilizar uma imagem do fast-data-dev que contém uma interface gráfica e todas as demais ferramentas como Zookeeper, Cluster Kafka, Schema Registry e Kafka Connect. Utilizaremos o Localstack para simular o serviço da AWS e vamos utilizar o aws-cli para executar e para visualizar a Lambda criada, mas se você gostar de algo mais visual, existe uma [interface gráfica](https://docs.localstack.cloud/user-guide/web-application/), caso tenha interesse, tem este [vídeo bem legal sobre o Localstack no Youtube](https://www.youtube.com/watch?v=1ow0NQv5Fsk).

![Tela da interface gráfica do Locastack Web mostrando os logs de execução de uma Lambda](./images/tela-localstack-web-logs-lambda.png)
_Tela da interface gráfica do Locastack Web mostrando os logs de execução de uma Lambda_


O connector Kafka precisa de uma plugin e para isso vamos utilizar o [plugin Lambda Sink](https://github.com/adrianoavelino/kafka-connect-lambda-localstack) com suporte ao Localstack. O plugin que vamos utilizar é um fork do projeto [kafka-connect-lambda](https://github.com/Nordstrom/kafka-connect-lambda) que **"não funciona"** com Localstack (ao menos não consegui executar usando o Localstack), caso tenha interesse fique a vontade para colaborar, contribuições são bem vindas rsrs.

![Tela da interface gráfica do fast-data-dev mostrando o conector Lambda Sink](./images/tela-fast-data-dev-conector-lambda-sink.png)
_Tela da interface gráfica do fast-data-dev mostrando o conector Lambda Sink_

Durante o desenvolvimento do projeto, utilizaremos um **producer** para enviar mensagens ao tópico Kafka. Há diversas opções para isso, como:

- Linha de comando com o `kafka-console-producer` no container Kafka
- [Kafkacat](https://github.com/edenhill/kcat)
- JMeter com o plugin Kafka (veja a seção [Dicas e recomendações](#Dicas-e-recomendações) para detalhes de configuração)
- Conector Data *source* como o [Voluble](https://github.com/MichaelDrogalis/voluble)
- Outras ferramentas gráficas ou de linha de comando
- Ou ainda, criar uma aplicação customizada usando a sua linguagem de programação preferida

Neste tutorial, usaremos o `kafka-console-producer` para simplificar o processo e evitar a introdução de mais uma ferramenta.

![Tela da interface gráfica do Jmeter com um plugin producer Kafka enviado diversas mensagens num tópico Kafka](./images/tela-jmeter-plugin-di-kafkameter-com-producer.png)
_Tela da interface gráfica do Jmeter com um plugin producer Kafka enviado diversas mensagens num tópico Kafka_







## Criação dos arquivos de configuração
Crie o arquivo `./docker-compose.yml`:
```yml
services:
  fast-data-dev:
    image: landoop/fast-data-dev:3.3
    ports:
      - "2181:2181"
      - "3030:3030"
      - "8081-8083:8081-8083"
      - "9581-9585:9581-9585"
      - "9092:9092"
    environment:
      ADV_HOST: 127.0.0.1
      DEBUG: 1
      RUNTESTS: 0
      AWS_ACCESS_KEY_ID: local
      AWS_SECRET_ACCESS_KEY: local
      CONNECT_PLUGIN_PATH: /var/run/connect/connectors/stream-reactor,/var/run/connect/connectors/third-party,/connectors
    volumes:
      - ./plugins:/connectors/kafka-connect-lambda-localstack
    network_mode: host

  localstack:
    container_name: "${LOCALSTACK_DOCKER_NAME-localstack-main}"
    image: localstack/localstack:2.3
    ports:
      - "127.0.0.1:4566:4566"            # LocalStack Gateway
      - "127.0.0.1:4510-4559:4510-4559"  # external services port range
    environment:
      - DEBUG=${DEBUG-}
      - DOCKER_HOST=unix:///var/run/docker.sock
    volumes:
      - "${LOCALSTACK_VOLUME_DIR:-./volume}:/var/lib/localstack"
      - "/var/run/docker.sock:/var/run/docker.sock"
    depends_on: [fast-data-dev]
    network_mode: host
```

Crie o arquivo `./cloudformation.yml` para criação da Lambda:
```yml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Lambda connector example function'
Resources:
  ExampleFunction:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: example-function
      Handler: index.handler
      Runtime: python3.7
      Role: !GetAtt 'ExampleFunctionRole.Arn'
      Code:
        ZipFile: |
          import json
          def handler(event, context):
            print(json.dumps(event))
            return event

  ExampleFunctionRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: example-lambda-role
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
        - Effect: Allow
          Principal:
            Service: lambda.amazonaws.com
          Action: sts:AssumeRole
      ManagedPolicyArns:
      - arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

Outputs:
  ExampleFunctionArn:
    Value: !GetAtt 'ExampleFunction.Arn'
  ExampleFunctionRoleArn:
    Value: !GetAtt 'ExampleFunctionRole.Arn'
```

Crie o arquivo de configuração `./connector-localstack.json`:
```json
{
  "name": "example-lambda-connector-localstack",
  "config": {
    "tasks.max": "1",
    "connector.class": "com.nordstrom.kafka.connect.lambda.LambdaSinkConnector",
    "topics": "example-stream",
    "key.converter": "org.apache.kafka.connect.storage.StringConverter",
    "value.converter": "org.apache.kafka.connect.storage.StringConverter",
    "aws.region": "us-east-1",
    "aws.lambda.function.arn": "arn:aws:lambda:us-east-1:000000000000:function:example-function",
    "aws.lambda.invocation.timeout.ms": "60000",
    "aws.lambda.invocation.mode": "SYNC",
    "aws.lambda.batch.enabled": "false",
    "localstack.enabled": "true"
  }
}
```

Baixe o plugin do conector Lambda Sink e salve numa pasta chamada `plugins`, na raiz do projeto, no mesmo local do seu arquivo **docker-compose.yml**, utilizando o `curl` execute o seguinte comando no terminal:
```bash
curl -L -o ./plugins/kafka-connect-lambda-localstack-1.4.0.jar \
https://github.com/adrianoavelino/kafka-connect-lambda-localstack/releases/download/v1.4.0/kafka-connect-lambda-localstack-1.4.0.jar
```

> Atualmente a última versão é a [1.4.0](https://github.com/adrianoavelino/kafka-connect-lambda-localstack/releases/tag/v1.4.0), mas para ter acesso a versão mais atualizada acesse as [releases no Github](https://github.com/adrianoavelino/kafka-connect-lambda-localstack/releases).

Veja abaixo a lista dos arquivos criados:
```tree
.
├── cloudformation.yml
├── connector-localstack.json
├── docker-compose.yml
├── plugins
│   └── kafka-connect-lambda-localstack-1.4.0.jar
```

## Criação da infrastrutura


### Criação dos containers
Inicie os containers docker do Kafka e Localstack:
```bash
docker compose up -d
```

> Se você é uma pessoa como eu que adora acompanhar o passo de cada informação nos logs, é possível utilizar o comando `docker compose logs -f`.

Para garantir que tudo está funcionando como devia, podemos realizar algumas verificações:
- `docker compose ps`: para validar se os containers estão `healthy`
- Acessar o endereço [http://localhost:3030/](http://localhost:3030/) para acessar a interface gráfica do Landoop para visualizar os tópicos, conectores e plugins de conectores.
- `curl --url http://localhost:8083/connector-plugins/`: listas os plugins de conectores disponíveis, verifique se o plugin com a class `com.nordstrom.kafka.connect.lambda.LambdaSinkConnector` está disponível.

### Criação da lambda
Crie uma Lambda no Localstack utilizando Cloudformation:
```bash
aws cloudformation create-stack \
--stack-name example-lambda-stack \
--capabilities CAPABILITY_NAMED_IAM \
--template-body file://cloudformation.yml \
--endpoint-url http://localhost:4566
```

Se a stack com a Lambda e demais dependencias for criada com sucesso, você deve ver uma saída semelhante ao exemplo abaixo:
```bash
{
    "StackId": "arn:aws:cloudformation:us-east-1:000000000000:stack/example-lambda-stack/d61cbd21"
}
```

Para verificar se a Lambda foi criada com sucesso, execute o seguinte comando:
```bash
aws lambda list-functions --endpoint-url=http://localhost:4566
```

Se tudo ocorreu como esperado, você deve ver uma saída semelhante ao exemplo abaixo:
```json
{
    "Functions": [
        {
            "FunctionName": "example-function",
            "FunctionArn": "arn:aws:lambda:us-east-1:000000000000:function:example-function",
            "Runtime": "python3.7",
            "Role": "arn:aws:iam::000000000000:role/example-lambda-role",
            "Handler": "index.handler",
            "CodeSize": 1630,
            "Description": "",
            "Timeout": 3,
            "MemorySize": 128,
            "LastModified": "2024-09-09T01:17:54.471773+0000",
            "CodeSha256": "qDSOE5NTun0FiK+cFAAZGHPqarSjlyJtlGMCPPRpJ8Y=",
            "Version": "$LATEST",
            "TracingConfig": {
                "Mode": "PassThrough"
            },
            "RevisionId": "debe4c55-40b0-46e3-94b4-acfc1aeb17fb",
            "PackageType": "Zip",
            "Architectures": [
                "x86_64"
            ],
            "EphemeralStorage": {
                "Size": 512
            },
            "SnapStart": {
                "ApplyOn": "None",
                "OptimizationStatus": "Off"
            }
        }
    ]
}
```

Agora antes de irmos ao próximo passo, vamos fazer um teste em nossa Lambda:
```bash
aws lambda invoke --function-name example-function \
--cli-binary-format raw-in-base64-out \
--payload '{"value": "my example"}' --output text result.txt \
--endpoint-url http://localhost:4566
```
Se tudo ocorreu bem você deve receber a seguinte resposta:
```bash
$LATEST Unhandled       200
```
Ou podemos validar o conteúdo do arquivo result.txt:
```bash
cat result.txt
# {"value": "my example"}
```

### Criação do conector
A criação do conector Lambda Sink é realizada via [API Kafka Connect REST](https://docs.confluent.io/platform/current/connect/references/restapi.html) ou na interface gráfica do [Landoop](http://localhost:3030/). Aqui estaremos utilizando o curl para realizar as requisições, mas nada impede de criar as requisições utilizando um aplicativo como o [Insomnia](https://insomnia.rest/download) ou outro:
```bash
curl -XPOST -H "Content-Type: application/json" \
http://localhost:8083/connectors \
-d @connector-localstack.json
```

Você deve receber a seguinte resposta:
```json
{
	"name": "example-lambda-connector-localstack",
	"config": {
		"tasks.max": "1",
		"connector.class": "com.nordstrom.kafka.connect.lambda.LambdaSinkConnector",
		"topics": "example-stream",
		"key.converter": "org.apache.kafka.connect.storage.StringConverter",
		"value.converter": "org.apache.kafka.connect.storage.StringConverter",
		"aws.region": "us-east-1",
		"aws.lambda.function.arn": "arn:aws:lambda:us-east-1:000000000000:function:example-function",
		"aws.lambda.invocation.timeout.ms": "60000",
		"aws.lambda.invocation.mode": "SYNC",
		"aws.lambda.batch.enabled": "false",
		"localstack.enabled": "true",
		"name": "example-lambda-connector-localstack"
	},
	"tasks": [],
	"type": "sink"
}
```

Para validarmos o conector criado podemos realizar outra requisição HTTP usando curl para verificar o status do conector:
```bash
curl --request GET \
  --url http://localhost:8083/connectors/example-lambda-connector-localstack/status 
```
A resposta deve se algo como:
```json
{
	"name": "example-lambda-connector-localstack",
	"connector": {
		"state": "RUNNING",
		"worker_id": "127.0.0.1:8083"
	},
	"tasks": [
		{
			"id": 0,
			"state": "RUNNING",
			"worker_id": "127.0.0.1:8083"
		}
	],
	"type": "sink"
}
```
> Obs.: podemos utilizar esse mesmo comando para identificar algum problema na integração do conector Kafka com a Lambda no Localstack.

## Enviar mensagem no kafka
```bash
echo "teste" | docker compose exec -T fast-data-dev \
kafka-console-producer \
--broker-list localhost:9092 \
--topic example-stream
```
> Obs: em caso de problema de comunicação com o broker ou outro serviço utilize o comando: `nc -vz localhost <PORTA>`. Ex: `nc -vz localhost 9092`

Caso você prefira manter um terminal ativo para estar enviando os eventos para o tópico Kafka, é possível utilizar o seguinte comando:
```bash
docker compose exec fast-data-dev \
kafka-console-producer \
--broker-list localhost:9092 \
--topic example-stream
```

Se tudo der certo certo você deve estar vendo um `>` para inserir as suas mensagens ao tópico Kafka. Exemplos de mensagens:
```bash
{"value": "my example"}
```

```bash
{"value": "my example 2"}
```

Para visualizar os logs de execução da Lambda no terminal:
```bash
LOG_GROUP=`aws logs describe-log-groups \
--endpoint-url http://localhost:4566 \
--query "logGroups[0].logGroupName" | sed 's/"//g'`

aws logs tail $LOG_GROUP --follow --endpoint-url http://localhost:4566
```

A resposta esperada é algo semelhante ao exempĺo abaixo:
```bash
2024-09-15T18:27:34.888000+00:00 2024/09/15/[$LATEST]57661289d19ebedfe4a6782395866989 START RequestId: 61ab5b4f-569a-4348-905b-b15ceadfcc26 Version: $LATEST
2024-09-15T18:27:34.902000+00:00 2024/09/15/[$LATEST]57661289d19ebedfe4a6782395866989 {"key": "", "keySchemaName": null, "value": "teste", "valueSchemaName": null, "topic": "example-stream", "partition": 0, "offset": 1, "timestamp": 1726424854776, "timestampTypeName": "CreateTime"}
2024-09-15T18:27:34.917000+00:00 2024/09/15/[$LATEST]57661289d19ebedfe4a6782395866989 END RequestId: 61ab5b4f-569a-4348-905b-b15ceadfcc26
2024-09-15T18:27:34.932000+00:00 2024/09/15/[$LATEST]57661289d19ebedfe4a6782395866989 REPORT RequestId: 61ab5b4f-569a-4348-905b-b15ceadfcc26	Duration: 7.85 ms	Billed Duration: 8 msMemory Size: 128 MB	Max Memory Used: 128 MB
```
> Obs.: Não se esqueça que também podemos ver os logs de execução da Lambda na [interface gráfica do Localstack](https://app.localstack.cloud/inst/default/resources).

## Alguns erros e soluções para identificarmos os problemas
- Function not found: arn:aws:lambda:us-east-1:000000000000:function:example-function : arn da lambda diferente do criado no localsctack. Sua lambda pode ter sido criada numa região diferente.

## Links
