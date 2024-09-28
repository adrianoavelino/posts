---
title: Conector Kafka Lambda Sink com Localstack
published: false
description: 
tags: 
# cover_image: https://direct_url_to_image.jpg
# Use a ratio of 100:42 for best results.
# published_at: 2024-09-01 21:51 +0000
---

## Introdução
Ao trabalhar em projetos corporativos, é comum mover informações de um lugar para outro utilizando o Kafka e seus conectores *source* e *sink*. Os conectores *source* são responsáveis por enviar dados aos tópicos Kafka, enquanto os conectores **sink** exportam essas informações para sistemas externos, como bancos de dados, ferramentas de log ou serviços na AWS, como uma *Lambda*. Neste tutorial, abordaremos especificamente o conector *sink*, mais precisamente o **Lambda Sink Connector**, utilizando o [Localstack](https://www.localstack.cloud/) para simular o serviço AWS Lambda.

## Pré-requisitos
Antes de começar, certifique-se de ter os seguintes itens configurados no seu ambiente:

- **Docker**: para criar os containers que rodarão o Kafka e o Localstack.
- **Docker Compose**: para orquestrar os containers.
- **[AWS CLI](https://docs.aws.amazon.com/pt_br/cli/latest/userguide/getting-started-install.html)**: necessário para executar comandos relacionados à AWS.
- **cURL ou uma ferramenta similar como o Insomnia**: para realizar requisições HTTP.
- Arquivo de configuração AWS (`~/.aws/config`) configurado da seguinte forma:

```bash
[default]
region = us-east-1
output = json
```

## Sobre o projeto
O objetivo deste projeto é simular um ambiente corporativo usando Kafka e AWS Lambda, de forma acessível e sem custos, utilizando o [Localstack](https://www.localstack.cloud/). Isso permite que você emule serviços da AWS localmente, facilitando o desenvolvimento e testes.

No fluxo deste projeto, uma mensagem é enviada por um **producer** para um tópico Kafka, que por sua vez dispara um evento para o conector Kafka Sink. O conector envia essa mensagem para uma função Lambda, conforme ilustrado no diagrama abaixo:

![Fluxograma do conector Lambda Sink. Producer enviando mensagem para um tópico Kafka que dispara um evento para o conector que envia a mensagem para uma Lambda](./fluxo-conector-lambda-sink.drawio.svg)

Para isso, utilizaremos o **Docker Compose** para gerenciar os containers do Kafka e do Localstack. A imagem Docker **fast-data-dev** será usada para o Kafka, pois já inclui uma interface gráfica e ferramentas como **Zookeeper**, **Kafka Cluster**, **Schema Registry** e **Kafka Connect**. O Localstack será usado para emular serviços da AWS, incluindo a Lambda.

Se você preferir uma visualização gráfica da Lambda em execução, o Localstack possui uma [interface web](https://docs.localstack.cloud/user-guide/web-application/). Além disso, existe um [vídeo introdutório sobre o Localstack no YouTube](https://www.youtube.com/watch?v=1ow0NQv5Fsk), caso queira entender mais sobre a ferramenta.

![Tela da interface gráfica do Localstack Web mostrando os logs de execução de uma Lambda](./images/tela-localstack-web-logs-lambda.png)
_Tela da interface gráfica do Localstack Web mostrando os logs de execução de uma Lambda._

Para configurar o Kafka Connect, utilizaremos o [plugin Lambda Sink](https://github.com/adrianoavelino/kafka-connect-lambda-localstack) que oferece suporte ao Localstack. Este plugin é um fork do projeto [kafka-connect-lambda](https://github.com/Nordstrom/kafka-connect-lambda), que não funciona com o Localstack. Caso tenha interesse em contribuir, a sua contribuição é bem-vinda!

![Tela da interface gráfica do fast-data-dev mostrando o conector Lambda Sink](./images/tela-fast-data-dev-conector-lambda-sink.png)
_Tela da interface gráfica do fast-data-dev mostrando o conector Lambda Sink._

Para enviar mensagens ao tópico Kafka, usaremos um **producer**. Existem diversas opções para isso:

- **Linha de comando**: Usando o `kafka-console-producer` do container Kafka.
- **[Kafkacat](https://github.com/edenhill/kcat)**: Ferramenta de linha de comando para interagir com o Kafka.
- **JMeter com o plugin Kafka**: Veja mais detalhes na seção [Dicas e Recomendações](#Dicas-e-Recomendações).
- **Conector Data Source como o [Voluble](https://github.com/MichaelDrogalis/voluble)**.
- Criar uma aplicação customizada na sua linguagem de programação preferida.

Para simplificar, neste tutorial, utilizaremos o `kafka-console-producer`.

![Tela do terminal executando Kafka Console Producer na linha de comando](./images/tela-terminal-executando-kafka-console-producer.png)
_Tela do terminal executando Kafka Console Producer na linha de comando_

## Criação dos arquivos de configuração
### Docker Compose
Começaremos criando o arquivo **docker-compose.yml**, que será responsável por orquestrar os containers do Kafka e do Localstack. Ele define os serviços necessários, como o Kafka (com a imagem **fast-data-dev**) e o Localstack para emular a AWS. Crie o arquivo `./docker-compose.yml` com o seguinte conteúdo:

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

### CloudFormation
Agora, criaremos um arquivo **cloudformation.yml** para provisionar a função Lambda simulada no Localstack. O arquivo também define as permissões necessárias para a execução da Lambda. Crie o arquivo `./cloudformation.yml` com o seguinte conteúdo:
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

### Configuração do conector Kafka
Agora, crie o arquivo de configuração do **conector Lambda Sink**. Este arquivo define as propriedades do conector, incluindo o tópico Kafka e a função Lambda a ser invocada. Crie o arquivo `./connector-localstack.json` com o seguinte conteúdo:
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

### Download do plugin Lambda Sink
Por fim, faça o **download do plugin Lambda Sink** e salve-o no diretório `./plugins`. Execute o seguinte comando no terminal:
```bash
curl -L -o ./plugins/kafka-connect-lambda-localstack-1.4.0.jar \
https://github.com/adrianoavelino/kafka-connect-lambda-localstack/releases/download/v1.4.0/kafka-connect-lambda-localstack-1.4.0.jar
```
> A última versão do plugin é a [1.4.0](https://github.com/adrianoavelino/kafka-connect-lambda-localstack/releases/tag/v1.4.0). Para versões mais recentes, consulte as [releases no GitHub](https://github.com/adrianoavelino/kafka-connect-lambda-localstack/releases).

### Estrutura final do projeto
Ao finalizar esta etapa, a estrutura de arquivos do projeto deverá ser semelhante a esta:
```
.
├── cloudformation.yml
├── connector-localstack.json
├── docker-compose.yml
├── plugins
│   └── kafka-connect-lambda-localstack-1.4.0.jar
```

## Criação da infrastrutura
### Inicialização dos containers
Inicie os containers do Kafka e do Localstack com o seguinte comando:
```bash
docker compose up -d
```

> Se você é uma pessoa como eu que adora acompanhar o passo a passo de cada informação nos logs, é possível utilizar o comando `docker compose logs -f`.

Para garantir que tudo está funcionando como devia, podemos realizar algumas verificações:
- `docker compose ps`: para validar se os containers estejam no estado `healthy`
- Acesse o endereço [http://localhost:3030/](http://localhost:3030/) para acessar a interface gráfica do Landoop para visualizar os tópicos, conectores e plugins dos conectores instalados.
- `curl --url http://localhost:8083/connector-plugins/`: listas os plugins de conectores disponíveis, verifique se o plugin com a class `com.nordstrom.kafka.connect.lambda.LambdaSinkConnector` está disponível.

### Criação da lambda
Crie uma Lambda no Localstack utilizando **Cloudformation** com seguinte comando:
```bash
aws cloudformation create-stack \
--stack-name example-lambda-stack \
--capabilities CAPABILITY_NAMED_IAM \
--template-body file://cloudformation.yml \
--endpoint-url http://localhost:4566
```

Se a stack for criada com sucesso, a saída será semelhante a esta:
```bash
{
    "StackId": "arn:aws:cloudformation:us-east-1:000000000000:stack/example-lambda-stack/d61cbd21"
}
```

Para verificar se a Lambda foi criada corretamente, execute:
```bash
aws lambda list-functions --endpoint-url=http://localhost:4566
```

A saída esperada será semelhante ao exemplo abaixo:
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

Para testar a Lambda, use o seguinte comando:
```bash
aws lambda invoke --function-name example-function \
--cli-binary-format raw-in-base64-out \
--payload '{"value": "my example"}' --output text result.txt \
--endpoint-url http://localhost:4566
```

Se tudo ocorreu bem, você deve receber a seguinte resposta:
```bash
$LATEST Unhandled       200
```

### Criação do conector
A criação do conector Lambda Sink pode ser feita via [API Kafka Connect REST](https://docs.confluent.io/platform/current/connect/references/restapi.html) ou pela interface gráfica do [Landoop](http://localhost:3030/). Neste exemplo, utilizaremos o `curl` para enviar as requisições, mas você também pode usar ferramentas como o [Insomnia](https://insomnia.rest/download) ou similares.

```bash
curl -XPOST -H "Content-Type: application/json" \
http://localhost:8083/connectors \
-d @connector-localstack.json
```
> Dica: No Insomnia, você pode importar comandos **curl** para gerar a requisição automaticamente. Confira este [vídeo tutorial](https://www.youtube.com/watch?v=wGzQrWcUcjc) ou consulte a [documentação oficial](https://docs.insomnia.rest/insomnia/import-export-data#import-data) para mais detalhes.

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

Para validar o status do conector, execute o seguinte comando **curl**:
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
> **Observação:** Este comando também pode ser utilizado para diagnosticar problemas de integração entre o conector Kafka e a Lambda no Localstack.

## Enviar mensagem no kafka

### Opção 1: Envio rápido de mensagem única
Utilize o comando abaixo para enviar uma mensagem única ao Kafka de forma rápida:
```bash
echo "teste" | docker compose exec -T fast-data-dev \
kafka-console-producer \
--broker-list localhost:9092 \
--topic example-stream
```
> Obs: em caso de problema de comunicação com o broker ou outro serviço utilize o comando: `nc -vz localhost <PORTA>`. Ex: `nc -vz localhost 9092`

### Opção 2: Envio contínuo de mensagens
Se preferir manter um terminal ativo para enviar várias mensagens ao Kafka, utilize o seguinte comando:
```bash
docker compose exec fast-data-dev \
kafka-console-producer \
--broker-list localhost:9092 \
--topic example-stream
```

Após a execução, você verá o prompt `>`, onde poderá inserir várias mensagens ao tópico Kafka. Exemplo de mensagens:
```bash
{"value": "my example"}
{"value": "my example 2"}
```

## Como visualizar os logs da Lambda no terminal
Para visualizar os logs da execução da Lambda diretamente no terminal, siga os passos abaixo:

1. Primeiro, obtenha o nome do grupo de logs da Lambda:
```bash
LOG_GROUP=`aws logs describe-log-groups \
--endpoint-url http://localhost:4566 \
--query "logGroups[0].logGroupName" | sed 's/"//g'`
```

2. Depois, use o comando aws logs tail para seguir os logs em tempo real:
```bash
aws logs tail $LOG_GROUP --follow --endpoint-url http://localhost:4566
```

A resposta esperada é algo semelhante ao exempĺo abaixo:
```bash
2024-09-15T18:27:34.888000+00:00 2024/09/15/[$LATEST]57661289d19ebedfe4a6782395866989 START RequestId: 61ab5b4f-569a-4348-905b-b15ceadfcc26 Version: $LATEST
2024-09-15T18:27:34.902000+00:00 2024/09/15/[$LATEST]57661289d19ebedfe4a6782395866989 {"key": "", "keySchemaName": null, "value": "teste", "valueSchemaName": null, "topic": "example-stream", "partition": 0, "offset": 1, "timestamp": 1726424854776, "timestampTypeName": "CreateTime"}
2024-09-15T18:27:34.917000+00:00 2024/09/15/[$LATEST]57661289d19ebedfe4a6782395866989 END RequestId: 61ab5b4f-569a-4348-905b-b15ceadfcc26
2024-09-15T18:27:34.932000+00:00 2024/09/15/[$LATEST]57661289d19ebedfe4a6782395866989 REPORT RequestId: 61ab5b4f-569a-4348-905b-b15ceadfcc26	Duration: 7.85 ms	Billed Duration: 8 msMemory Size: 128 MB	Max Memory Used: 128 MB
```

> **Observação:** também é possível visualizar os logs da Lambda diretamente na [interface gráfica do Localstack](https://app.localstack.cloud/inst/default/resources).

## Automatização
Parabéns! Se você chegou até aqui, já percorreu um longo caminho e fez tudo manualmente  ou ... você foi uma pessoa "espertinha" e encontrou um atalho aqui para chegar no parque de diversão.

Aqui não vamos precisar criar os arquivos de configuração e nem a criação da infraestrutura de forma manual, tudo está automatizado. Seguindo os passo abaixo você terá o ambiente completo configurado para enviar mensagens ao tópico Kafka e validar os logs. Vamos a prática:

Clone o repositório:
```bash
git clone https://github.com/adrianoavelino/posts.git
```

Entre no diretório `automation`:
```bash
cd dev.to/2024-09-01-conector-lambda-sink-localstack/automation/
```

Inicie os containers:
```bash
docker compose up
```

Agora é só aguardar a inicialização e criação da lambda e conector Lambda Sink para inicar os testes. Se rodou ocorreu como planejado você deve ver algo paracedo com o exemplo abaixo:
```bash
localstack-main  | ########### script 02 - Lambda function has been invoked ###########
fast-data-dev-1  | Sat 28 Sep 2024 02:15:31 AM UTC  Kafka Connect listener HTTP state:  000  (waiting for 200)
fast-data-dev-1  | Sat 28 Sep 2024 02:15:36 AM UTC  Kafka Connect listener HTTP state:  000  (waiting for 200)
fast-data-dev-1  | Sat 28 Sep 2024 02:15:41 AM UTC  Kafka Connect listener HTTP state:  000  (waiting for 200)
fast-data-dev-1  | Sat 28 Sep 2024 02:15:47 AM UTC  Kafka Connect listener HTTP state:  200  (waiting for 200)
fast-data-dev-1  | 
fast-data-dev-1  | --
fast-data-dev-1  | +> Creating Lambda Sink Connector with avro
fast-data-dev-1  | {"name":"example-lambda-connector-localstack","config":{"tasks.max":"1","connector.class":"com.nordstrom.kafka.connect.lambda.LambdaSinkConnector","topics":"example-stream","key.converter":"org.apache.kafka.connect.storage.StringConverter","value.converter":"org.apache.kafka.connect.storage.StringConverter","aws.region":"us-east-1","aws.lambda.function.arn":"arn:aws:lambda:us-east-1:000000000000:function:example-function","aws.lambda.invocation.timeout.ms":"60000","aws.lambda.invocation.mode":"SYNC","aws.lambda.batch.enabled":"false","localstack.enabled":"true","name":"example-lambda-connector-localstack"},"tasks":[],"type":"sink"}2024-09-28 02:15:53,267 INFO exited: logs-to-kafka (exit status 0; expected)
```

Execute o seguinte comando para enviar um envento ao tópico Kafka:
```bash
echo "teste" | docker compose exec -T fast-data-dev \
kafka-console-producer \
--broker-list localhost:9092 \
--topic example-stream
```

Agora você pode começar a realizar seus testes e ajustar a configuração conforme necessário. Se encontrar algum problema, não se preocupe, basta verificar os logs dos containers para identificar possíveis erros. E deixa eu te contar mais um segredo, deixei várias dicas legais logo abaixo.

## Alguns erros e soluções para identificarmos os problemas
A primeira dica é sempre [olhar os logs dos containers](https://docs.docker.com/reference/cli/docker/compose/logs/) para identificar algum comportamento ou mensagem de erro que possa dar uma ideia do problema. Ah, você pode visualizar os logs separados por serviços, como por exemplo, `docker compose logs -f localstack` ou `docker compose logs -f fast-data-dev`.

No caso do serviço **fast-data-dev**, alguns logs não são exibidos com o comando acima. Você pode ver os logs no arquivo `/var/log/broker.log`, no container, usando o comando `docker compose exec fast-data-dev cat /var/log/broker.log`. Está e outras informações do **fast-data-dev** podem ser vistas no [Docker Hub](https://hub.docker.com/r/landoop/fast-data-dev).


**Function not found arn:aws:lambda:us-east-1:000000000000:function:example-function**: arn da lambda diferente do criado no localstack. Sua lambda pode ter sido criada numa região diferente. Verifique o seu arquivo de configuração do aws-cli (`~/.aws/config`).

Erros no conector podem ser encontrados através da [api do Kafka Connect](https://docs.confluent.io/platform/current/connect/references/restapi.html#get--connectors-(string-name)-status) usando o seguinte comando:
```bash
curl --request GET \
--url http://localhost:8083/connectors/example-lambda-connector-localstack/status \
--header 'User-Agent: insomnia/9.3.3'
```

 Exemplo de erro quando não existe uma lambda function criada no localstack:
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
			"state": "FAILED",
			"worker_id": "127.0.0.1:8083",
			"trace": "org.apache.kafka.connect.errors.ConnectException: Exiting WorkerSinkTask due to unrecoverable exception.\n\tat org.apache.kafka.connect.runtime.WorkerSinkTask.deliverMessages(WorkerSinkTask.java:611)\n\tat org.apache.kafka.connect.runtime.WorkerSinkTask.poll(WorkerSinkTask.java:333)\n\tat org.apache.kafka.connect.runtime.WorkerSinkTask.iteration(WorkerSinkTask.java:234)\n\tat org.apache.kafka.connect.runtime.WorkerSinkTask.execute(WorkerSinkTask.java:203)\n\tat org.apache.kafka.connect.runtime.WorkerTask.doRun(WorkerTask.java:189)\n\tat org.apache.kafka.connect.runtime.WorkerTask.run(WorkerTask.java:244)\n\tat java.base/java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:515)\n\tat java.base/java.util.concurrent.FutureTask.run(FutureTask.java:264)\n\tat java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1128)\n\tat java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:628)\n\tat java.base/java.lang.Thread.run(Thread.java:829)\nCaused by: com.nordstrom.kafka.connect.lambda.InvocationClient$InvocationException: java.util.concurrent.ExecutionException: com.amazonaws.services.lambda.model.ResourceNotFoundException: Function not found: arn:aws:lambda:us-east-1:000000000000:function:example-function (Service: AWSLambda; Status Code: 404; Error Code: ResourceNotFoundException; Request ID: 52512fac-927b-4db0-a910-907270c4166f; Proxy: null)\n\tat com.nordstrom.kafka.connect.lambda.InvocationClient.invoke(InvocationClient.java:71)\n\tat com.nordstrom.kafka.connect.lambda.LambdaSinkTask.invoke(LambdaSinkTask.java:190)\n\tat com.nordstrom.kafka.connect.lambda.LambdaSinkTask.put(LambdaSinkTask.java:86)\n\tat org.apache.kafka.connect.runtime.WorkerSinkTask.deliverMessages(WorkerSinkTask.java:581)\n\t... 10 more\nCaused by: java.util.concurrent.ExecutionException: com.amazonaws.services.lambda.model.ResourceNotFoundException: Function not found: arn:aws:lambda:us-east-1:000000000000:function:example-function (Service: AWSLambda; Status Code: 404; Error Code: ResourceNotFoundException; Request ID: 52512fac-927b-4db0-a910-907270c4166f; Proxy: null)\n\tat java.base/java.util.concurrent.FutureTask.report(FutureTask.java:122)\n\tat java.base/java.util.concurrent.FutureTask.get(FutureTask.java:205)\n\tat com.nordstrom.kafka.connect.lambda.InvocationClient.invoke(InvocationClient.java:64)\n\t... 13 more\nCaused by: com.amazonaws.services.lambda.model.ResourceNotFoundException: Function not found: arn:aws:lambda:us-east-1:000000000000:function:example-function (Service: AWSLambda; Status Code: 404; Error Code: ResourceNotFoundException; Request ID: 52512fac-927b-4db0-a910-907270c4166f; Proxy: null)\n\tat com.amazonaws.http.AmazonHttpClient$RequestExecutor.handleErrorResponse(AmazonHttpClient.java:1819)\n\tat com.amazonaws.http.AmazonHttpClient$RequestExecutor.handleServiceErrorResponse(AmazonHttpClient.java:1403)\n\tat com.amazonaws.http.AmazonHttpClient$RequestExecutor.executeOneRequest(AmazonHttpClient.java:1372)\n\tat com.amazonaws.http.AmazonHttpClient$RequestExecutor.executeHelper(AmazonHttpClient.java:1145)\n\tat com.amazonaws.http.AmazonHttpClient$RequestExecutor.doExecute(AmazonHttpClient.java:802)\n\tat com.amazonaws.http.AmazonHttpClient$RequestExecutor.executeWithTimer(AmazonHttpClient.java:770)\n\tat com.amazonaws.http.AmazonHttpClient$RequestExecutor.execute(AmazonHttpClient.java:744)\n\tat com.amazonaws.http.AmazonHttpClient$RequestExecutor.access$500(AmazonHttpClient.java:704)\n\tat com.amazonaws.http.AmazonHttpClient$RequestExecutionBuilderImpl.execute(AmazonHttpClient.java:686)\n\tat com.amazonaws.http.AmazonHttpClient.execute(AmazonHttpClient.java:550)\n\tat com.amazonaws.http.AmazonHttpClient.execute(AmazonHttpClient.java:530)\n\tat com.amazonaws.services.lambda.AWSLambdaClient.doInvoke(AWSLambdaClient.java:4717)\n\tat com.amazonaws.services.lambda.AWSLambdaClient.invoke(AWSLambdaClient.java:4684)\n\tat com.amazonaws.services.lambda.AWSLambdaClient.invoke(AWSLambdaClient.java:4673)\n\tat com.amazonaws.services.lambda.AWSLambdaClient.executeInvoke(AWSLambdaClient.java:2619)\n\tat com.amazonaws.services.lambda.AWSLambdaAsyncClient$30.call(AWSLambdaAsyncClient.java:1248)\n\tat com.amazonaws.services.lambda.AWSLambdaAsyncClient$30.call(AWSLambdaAsyncClient.java:1242)\n\t... 4 more\n"
		}
	],
	"type": "sink"
}
```
> Não se esqueça, existe uma [interface gráfica do fast-data-dev]() para aqueles que gostam de algo visual.


## Links
