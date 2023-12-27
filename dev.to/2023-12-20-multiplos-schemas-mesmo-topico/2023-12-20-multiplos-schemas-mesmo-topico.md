---
title: Multiplos schemas no mesmo tópico Kafka na linha de comando 
published: false
description: Nesse passo a passo você vai aprender a utilizar mais de um schema avro num mesmo tópico Kafka
tags: 
# cover_image: https://direct_url_to_image.jpg
# Use a ratio of 100:42 for best results.
# published_at: 2023-12-20 01:34 +0000
---
Recentemente estive em contato com um projeto onde são utilizados três tipos de eventos (schemas) no mesmo tópico Kafka, até o momento só havia utilizado um schema avro por tópico. Isso só é possível devido ao uso da estratégia de nome do subject (Subject name strategy) no Schema Registry.

Um **subject** no Schema Registry é uma coleção de schemas associados a um tópico ou a um schema específico usado na serialização e desserialização de dados em um tópico do Kafka. Em termos simples, um "subject" é uma chave sob a qual os esquemas são registrados no Schema Registry. Como exemplos de nomes de **subjects** podemos citar: `transacoes-value` e `transacoes-key`, repectivamente relacionados ao schema de conteúdo e a key de identificação de um evento enviado a um tópico Kafka. O Schema Registry suporta outros tipos de schemas, mas estaremos abordando a utilização de schemas avro. Exemplos de schema avro:

```json
{
  "type": "record",
  "name": "Transacao",
  "fields": [
    {"name": "id", "type": "string"},
    {"name": "valor", "type": "double"},
    {"name": "data", "type": "long"},
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

Seguindo a estratégia de nome de subject padrão, o nome do **subject** num tópico chamado **transacoes** seria: `transacoes-value`.

> Mais informações relacionadas ao arquivo avro podem ser encontradas na [documentação da Apache Avro](https://avro.apache.org/docs/).

O uso de mais de um schema no mesmo tópico Kafka é possível através do uso da estratégia de nome do subject (Subject name strategy). Existem três opções: TopicNameStrategy, RecordNameStrategy e TopicRecordNameStrategy.

O `TopicNameStrategy` é o padrão e gera o nome do subject com base no nome do tópico seguido do caractere `-`, mais a palavra `key` ou `value`. No `RecordNameStrategy` o nome do subject é baseado no nome do record do schema avro seguido do caractere `-` mais a palavra `key` ou `value`. Já o `TopicRecordNameStrategy`, o nome subject é baseado no nome do tópico seguido do nome do record do schema avro. Veja a tabela abaixo com exemplos dos nomes gerados num tópico chamado **transacoes** e nome do record `br.com.DetalhesConta`:

| Nome da estratégia do Subject | Exemplo Subject gerado|
|-------------------------------|-----------------------|
| TopicNameStrategy             | transacoes-value ou transacoes-key|
| RecordNameStrategy            | br.com.contacorrente-key ou br.com.contacorrente-value|
| TopicRecordNameStrategy       | transacoes-br.com.contacorrente|

Seguindo essa lógica fica fácil entender porque não conseguimos utilizar mais de um schema utilizando a estratégia padrão (TopicNameStrategy). A formação do nome do subject é a mesma, tanto para um schema **Transacao** ou schema **DetalhesConta**, por exemplo. Ao cadastrar os schemas, ambos geram o mesmo nome do subject: `nomeDoTopico-value`.

## Referências
- [Subject name strategy](https://docs.confluent.io/platform/current/schema-registry/fundamentals/serdes-develop/index.html#subject-name-strategy)
