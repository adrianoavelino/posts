---
title: Multiplos schemas no mesmo tópico Kafka na linha de comando 
published: false
description: Nesse passo a passo você vai aprender a utilizar mais de um schema avro num mesmo tópico Kafka
tags: 
# cover_image: https://direct_url_to_image.jpg
# Use a ratio of 100:42 for best results.
# published_at: 2023-12-20 01:34 +0000
---
Recentemente, tive a oportunidade de trabalhar em um projeto que utiliza três tipos distintos de eventos (schemas) no mesmo tópico do Kafka. Até então, só havia utilizado um único schema Avro por tópico. Isso só foi possível devido ao uso da estratégia de nome do subject (Subject name strategy) no Schema Registry.

## Teoria
Um **subject** no Schema Registry é uma coleção de schemas associados a um tópico ou a um schema específico usado na serialização e desserialização de dados em um tópico do Kafka. Em termos simples, um "subject" é uma chave sob a qual os schemas são registrados no Schema Registry. Como exemplos de nomes de **subjects** podemos citar: `transacoes-value` e `transacoes-key`, repectivamente relacionados ao valor e a chave de identificação de um evento enviado a um tópico Kafka. 

O Schema Registry suporta diversos tipos de schemas, mas estaremos abordando a utilização de schemas avro, por exemplo:

```json
{
  "type": "record",
  "name": "Transacao",
  "fields": [
    {"name": "id", "type": "string"},
    {"name": "valor", "type": "double"},
    {"name": "data", "type": "string"},
    {"name": "tipo", "type": "string"},
    {"name": "conta_origem", "type": "string"},
    {"name": "conta_destino", "type": "string"},
    {"name": "descricao", "type": "string"}
  ]
}
```

```json
{
  "type": "record",
  "name": "DetalhesConta",
  "fields": [
    {"name": "conta_id", "type": "string"},
    {"name": "titular", "type": "string"},
    {"name": "saldo", "type": "double"},
    {"name": "tipo_conta", "type": "string"},
    {"name": "agencia", "type": "string"},
  ]
}
```

> Mais informações relacionadas a arquivos avro podem ser encontradas na [documentação do Apache Avro](https://avro.apache.org/docs/).

Seguindo a estratégia de nome de subject padrão, o nome do **subject** num tópico chamado **transacoes** seria: `transacoes-value`.

O uso de mais de um schema no mesmo tópico Kafka é possível através do uso da estratégia de nome do subject (Subject name strategy). Existem três opções: TopicNameStrategy, RecordNameStrategy e TopicRecordNameStrategy.

O **TopicNameStrategy** é o padrão e gera o nome do subject com base no nome do tópico seguido do caractere `-`, mais a palavra `key` ou `value`. No **RecordNameStrategy** o nome do subject é baseado no nome do record do schema avro. Já o **TopicRecordNameStrategy**, o nome subject é baseado no nome do tópico seguido  do caractere `-`, mais o nome do record do schema avro. Veja a tabela abaixo com exemplos dos nomes gerados num tópico chamado **transacoes** e nome do record `br.com.DetalhesConta`:

| Nome da estratégia do Subject | Exemplo Subject gerado|
|-------------------------------|-----------------------|
| TopicNameStrategy             | transacoes-value ou transacoes-key|
| RecordNameStrategy            | DetalhesConta|
| TopicRecordNameStrategy       | transacoes-DetalhesConta|

Seguindo essa lógica fica fácil entender porque não conseguimos utilizar mais de um schema utilizando a estratégia padrão (TopicNameStrategy). A formação do nome do subject é a mesma, tanto para um schema **Transacao** ou **DetalhesConta**, por exemplo. Ao cadastrar os schemas, ambos geram o mesmo nome do subject: `transacoes-value`.

## O problema
Vamos à prática, executando o ambiente Kafka no `docker-compose.yml` com o seguinte conteúdo:

```yml
version: '3.7'

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
```

E executando o comando abaixo:
```bash
docker-compose up -d
```

Agora vamos acessar o **bash** do container:
```bash
docker-compose exec fast-data-dev bash
```

Dentro do container podemos criar um producer que por padrão cria os subjects e os schemas de forma automática, primeiramente criamos um producer para o schema **Transacoes**:
```bash
kafka-avro-console-producer \
--broker-list localhost:9092 \
--topic transacoes \
--property value.schema='{ "type": "record", "name": "Transacao", "fields": [ {"name": "id", "type": "string"}, {"name": "valor", "type": "double"}, {"name": "data", "type": "string"}, {"name": "tipo", "type": "string"}, {"name": "conta_origem", "type": "string"}, {"name": "conta_destino", "type": "string"}, {"name": "descricao", "type": "string"} ] }' \
--property schema.registry.url=http://localhost:8081
```
Logo após, colamos o seguinte código:
```json
{ "id": "123456789", "valor": 500.0, "data": "2023-01-01", "tipo": "transferencia", "conta_origem": "987654321", "conta_destino": "567890123", "descricao": "Transferência entre contas" }
```

Com isso podemos visualizar os **subjects** cadastrados através da interface gráfica do container landoop, através do terminal utilizando o **curl** ou qualquer outra aplicação como o Postman ou Insomnia. Para acessar via interface gráfica do landoop, acesse o endereço [http://localhost:3030/schema-registry-ui/#/](http://localhost:3030/schema-registry-ui/#/) e filtre pelo nome do subject `transacoes-value`, conforme a imagem abaixo:

![Print da interface gráfica do landoop filtrando pelo termo transacoes-value](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/2w5ce7km72njh8mcfgy6.png)

Se preferir também pode utilizar o **curl** em um novo terminal:
```bash
curl -X GET http://localhost:8081/subjects
```
O resultado deve ser algo semelhante a imagem abaixo:

![Print com o exemplo da resposta para uma requisição na API do schema registry para listar os subjects registrados](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/me6bqan0uyxbp1qvnbdd.png)

> Obs: a reposta deve conter diversos **subjects**, mas vamos focar somente no subject `transacoes-value` para realizar a validação.

Vamos ver o que acontece ao criarmos mais um producer, mas para o schema **DetalhesConta**. Como comentado anteriormente, por padrão, o producer cria os subjects e os schemas de forma automática. O nosso objetivo ao utilizar um segundo producer é adicionar mais um schema no mesmo tópico e para isso primeiro abrimos um novo terminal e iniciamos o bash:
```bash
docker-compose exec fast-data-dev bash
```

Agora iniciamos o nosso producer:
```bash
kafka-avro-console-producer \
--broker-list localhost:9092 \
--topic transacoes \
--property value.schema='{ "type": "record", "name": "DetalhesConta", "fields": [ {"name": "conta_id", "type": "string"}, {"name": "titular", "type": "string"}, {"name": "saldo", "type": "double"}, {"name": "tipo_conta", "type": "string"}, {"name": "agencia", "type": "string"} ] }' \
--property schema.registry.url=http://localhost:8081
```

Logo após, colamos o seguinte evento para o schema `DetalhesConta`:
```json
{ "conta_id": "987654321", "titular": "Joaquim", "saldo": 1000.0, "tipo_conta": "corrente", "agencia": "123" }
```

Devemos receber uma mensagem de erro semelhante ao erro abaixo:
```
org.apache.kafka.common.errors.InvalidConfigurationException: Schema being registered is incompatible with an earlier schema for subject "transacoes-value", 
details: [Incompatibility{type:NAME_MISMATCH, location:/name, message:expected: Transacao, reader:{"type":"record","name":"DetalhesConta","fields":
[{"name":"conta_id","type":"string"},{"name":"titular","type":"string"},{"name":"saldo","type":"double"},{"name":"tipo_conta","type":"string"},
{"name":"agencia","type":"string"}]}, writer:{"type":"record","name":"Transacao","fields":[{"name":"id","type":"string"},{"name":"valor","type":"double"},
{"name":"data","type":"string"},{"name":"tipo","type":"string"},{"name":"conta_origem","type":"string"},{"name":"conta_destino","type":"string"},
{"name":"descricao","type":"string"}]}}, Incompatibility{type:READER_FIELD_MISSING_DEFAULT_VALUE, location:/fields/0, message:conta_id, reader:{"type":"record",
"name":"DetalhesConta","fields":[{"name":"conta_id","type":"string"},{"name":"titular","type":"string"},{"name":"saldo","type":"double"},{"name":"tipo_conta",
"type":"string"},{"name":"agencia","type":"string"}]}, writer:{"type":"record","name":"Transacao","fields":[{"name":"id","type":"string"},{"name":"valor",
"type":"double"},{"name":"data","type":"string"},{"name":"tipo","type":"string"},{"name":"conta_origem","type":"string"},{"name":"conta_destino",
"type":"string"},{"name":"descricao","type":"string"}]}}, Incompatibility{type:READER_FIELD_MISSING_DEFAULT_VALUE, location:/fields/1, message:titular, reader:
{"type":"record","name":"DetalhesConta","fields":[{"name":"conta_id","type":"string"},{"name":"titular","type":"string"},{"name":"saldo","type":"double"},
{"name":"tipo_conta","type":"string"},{"name":"agencia","type":"string"}]}, writer:{"type":"record","name":"Transacao","fields":[{"name":"id","type":"string"},
{"name":"valor","type":"double"},{"name":"data","type":"string"},{"name":"tipo","type":"string"},{"name":"conta_origem","type":"string"},
{"name":"conta_destino","type":"string"},{"name":"descricao","type":"string"}]}}, Incompatibility{type:READER_FIELD_MISSING_DEFAULT_VALUE, location:/fields/2, 
message:saldo, reader:{"type":"record","name":"DetalhesConta","fields":[{"name":"conta_id","type":"string"},{"name":"titular","type":"string"},{"name":"saldo",
"type":"double"},{"name":"tipo_conta","type":"string"},{"name":"agencia","type":"string"}]}, writer:{"type":"record","name":"Transacao","fields":[{"name":"id",
"type":"string"},{"name":"valor","type":"double"},{"name":"data","type":"string"},{"name":"tipo","type":"string"},{"name":"conta_origem","type":"string"},
{"name":"conta_destino","type":"string"},{"name":"descricao","type":"string"}]}}, Incompatibility{type:READER_FIELD_MISSING_DEFAULT_VALUE, location:/fields/3, 
message:tipo_conta, reader:{"type":"record","name":"DetalhesConta","fields":[{"name":"conta_id","type":"string"},{"name":"titular","type":"string"},
{"name":"saldo","type":"double"},{"name":"tipo_conta","type":"string"},{"name":"agencia","type":"string"}]}, writer:{"type":"record","name":"Transacao",
"fields":[{"name":"id","type":"string"},{"name":"valor","type":"double"},{"name":"data","type":"string"},{"name":"tipo","type":"string"},{"name":"conta_origem",
"type":"string"},{"name":"conta_destino","type":"string"},{"name":"descricao","type":"string"}]}}, Incompatibility{type:READER_FIELD_MISSING_DEFAULT_VALUE, 
location:/fields/4, message:agencia, reader:{"type":"record","name":"DetalhesConta","fields":[{"name":"conta_id","type":"string"},{"name":"titular",
"type":"string"},{"name":"saldo","type":"double"},{"name":"tipo_conta","type":"string"},{"name":"agencia","type":"string"}]}, writer:{"type":"record",
"name":"Transacao","fields":[{"name":"id","type":"string"},{"name":"valor","type":"double"},{"name":"data","type":"string"},{"name":"tipo","type":"string"},
{"name":"conta_origem","type":"string"},{"name":"conta_destino","type":"string"},{"name":"descricao","type":"string"}]}}]; error code: 409
```

A mensagem de erro é extensa, porém, resumidamente, o problema ocorreu ao tentar registrar automaticamente um novo schema, seguindo a estratégia de nome `TopicNameStrategy` que gera um subject chamado `transacoes-value`. Como este subject já foi registrado anteriormente, foi realizada uma tentativa de atualizar um schema tentado adicionar campos obrigatórios gerando erros de incompatibilidade. Esse erro está relacionado aos tipos de compatibilidade dos schemas, onde o padrão é `BACKWARD`. Esse padrão permite a exclusão de campos e a adição de campos opcionais. Mais informações sobre compatibilidade dos schemas podem ser encontradas na [documentação sobre Compatibility types](https://docs.confluent.io/cloud/current/sr/fundamentals/schema-evolution.html#compatibility-types).

> Dica: para finalizar o producer em qualquer um dos terminais abertos, basta digitar `Ctrl + C`

## Solução
Para resolver esse problema devemos utilizar a estratégia de nome de subject `TopicRecordNameStrategy` ou `RecordNameStrategy`. Aqui vamos utilizar a estratégia `TopicRecordNameStrategy`, mas antes vamos recriar a nossa infraestrutura seguindo alguns passos:

> Obs: esses passos não são obrigatórios, mas para mantermos o ambiente sem estados iremos recriar a infraestrutura

Desligue o container:
```bash
docker-compose down -v
```

Recrie a infraestrutura:
```bash
docker-compose up -d
```

Agora vamos registrar dois schemas para o mesmo tópico da seguinte forma:
Acesse o **bash** do container:
```bash
docker-compose exec fast-data-dev bash
```

Crie um producer para o schema **Transacoes**:
```bash
kafka-avro-console-producer \
--broker-list localhost:9092 \
--topic transacoes \
--property value.schema='{ "type": "record", "name": "Transacao", "fields": [ {"name": "id", "type": "string"}, {"name": "valor", "type": "double"}, {"name": "data", "type": "string"}, {"name": "tipo", "type": "string"}, {"name": "conta_origem", "type": "string"}, {"name": "conta_destino", "type": "string"}, {"name": "descricao", "type": "string"} ] }' \
--property schema.registry.url=http://localhost:8081 \
--property value.subject.name.strategy=io.confluent.kafka.serializers.subject.TopicRecordNameStrategy
```
Agora cole o seguinte evento:
```json
{ "id": "123456789", "valor": 500.0, "data": "2023-01-01", "tipo": "transferencia", "conta_origem": "987654321", "conta_destino": "567890123", "descricao": "Transferência entre contas" }
```

Agora vamos criar um producer para o schema `DetalhesConta`, primeiro abrimos um novo terminal e inciamos um bash para o container:
```bash
docker-compose exec fast-data-dev bash
```

Agora iniciamos o nosso producer:
```bash
kafka-avro-console-producer \
--broker-list localhost:9092 \
--topic transacoes \
--property value.schema='{ "type": "record", "name": "DetalhesConta", "fields": [ {"name": "conta_id", "type": "string"}, {"name": "titular", "type": "string"}, {"name": "saldo", "type": "double"}, {"name": "tipo_conta", "type": "string"}, {"name": "agencia", "type": "string"} ] }' \
--property schema.registry.url=http://localhost:8081 \
--property value.subject.name.strategy=io.confluent.kafka.serializers.subject.TopicRecordNameStrategy
```

Logo após, colamos o seguinte evento para o schema `DetalhesConta`:
```json
{ "conta_id": "987654321", "titular": "Joaquim", "saldo": 1000.0, "tipo_conta": "corrente", "agencia": "123" }
```

Com isso podemos validar os subjects na [interface gráfica do landoop](http://localhost:3030/schema-registry-ui/#/cluster/fast-data-dev) e pesquisar pela palavra `transacoes`:

![Print da interface gráfica do landoop pesquisando pelos schemas que contém a palavra transacoes](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/rg6mhek4ltku321dnozc.png)

Ou através do **curl** com o seguinte comando:
```bash
curl -X GET http://localhost:3030/schema-registry-ui/#/subjects
```

Ao analisar a resposta do comando acima podemos identificar que foram criados 2 subjects para o tópico **transacoes**: `transacoes-Transacao` e `transacoes-DetalhesConta`.

Também podemos visualizar os eventos recebidos no tópico Kafka usando a [interface gráfica do landoop](http://localhost:3030/kafka-topics-ui/#/cluster/fast-data-dev/topic/n/transacoes/):

![Print da interface gráfica do landoop listando os eventos do tópico transacoes](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/h2ixosqagwu1rx8870wl.png)

Ou através de um consumer na linha de comando, num outro terminal, após iniciar o bash com o comando `docker-compose exec fast-data-dev bash`:

```bash
kafka-avro-console-consumer \
--bootstrap-server localhost:9092 \
--topic transacoes \
--from-beginning \
--property schema.registry.url=http://localhost:8081
```

Ao finalizar o passo a passo será possível registrar dois schemas no mesmo tópico utilizando o `kafka-avro-console-producer`, de forma automática, através da estratégia de nome de subject `TopicRecordNameStrategy` para não sofrer com problemas de conflito de subjects no mesmo tópico. Você pode encontrar um exemplo dessa implantação em [Multi schemas in one Kafka topic](https://www.karengryg.io/2018/08/18/multi-schemas-in-one-kafka-topic/) utilizando a linguagem Java ou [outro exemplo em python](https://github.com/my-study-area/poc-kafka-connector-lambda/blob/main/run_local/multi-schema-same-topic-avro-producer.py)


## Referências
- [Schema Registry Key Concepts](https://docs.confluent.io/cloud/current/sr/fundamentals/index.html)
- [Subject name strategy](https://docs.confluent.io/platform/current/schema-registry/fundamentals/serdes-develop/index.html#subject-name-strategy)
- [Compatibility types](https://docs.confluent.io/cloud/current/sr/fundamentals/schema-evolution.html#compatibility-types)
- [Avroserializer](https://docs.confluent.io/platform/current/clients/confluent-kafka-python/html/index.html#avroserializer)
- [Apache Avro](https://avro.apache.org/docs/)
- [Imagem docker com o ecossitema Kafka](https://hub.docker.com/r/landoop/fast-data-dev)
- [Chat GPT](https://chat.openai.com/)
- [Should You Put Several Event Types in the Same Kafka Topic?](https://www.confluent.io/blog/put-several-event-types-kafka-topic/)
- [Multi schemas in one Kafka topic](https://www.karengryg.io/2018/08/18/multi-schemas-in-one-kafka-topic/)
