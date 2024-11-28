# posts
![GitHub top language](https://img.shields.io/github/languages/top/adrianoavelino/posts)
![Terraform Version](https://img.shields.io/badge/Terraform-v1.6.4-blue.svg)
[![Repository size](https://img.shields.io/github/repo-size/adrianoavelino/posts)](https://img.shields.io/github/repo-size/adrianoavelino/posts)
[![Last commit](https://img.shields.io/github/last-commit/adrianoavelino/posts)](https://github.com/adrianoavelino/posts/commits/master)

Posts

## dev.to
- [Multiplos schemas no mesmo tópico Kafka na linha de comando](https://dev.to/adrianoavelino/multiplos-schemas-no-mesmo-topico-kafka-na-linha-de-comando-1o0h)
- [Conector Kafka Lambda Sink com Localstack](https://dev.to/adrianoavelino/conector-kafka-lambda-sink-com-localstack-oe0)
- [📦 ASDF: Gerenciando versões de linguagens e ferramentas num lugar só](https://dev.to/adrianoavelino/asdf-gerenciando-versoes-de-linguagens-e-ferramentas-num-lugar-so-1lmh)


## Postagens de posts no Linkedin
### Gerencie Múltiplas Versões de Ferramentas com asdf!
🎯 Você já precisou gerenciar diferentes versões de linguagens de programação ou ferramentas para seus projetos? Se sim, você vai adorar o asdf!

Recentemente, testei o asdf para organizar e alternar versões de ferramentas como Node.js, Python e Java — tudo com um único gerenciador! 💡

Com o asdf, você elimina a necessidade de instalar diversos gerenciadores específicos (como nvm ou rbenv). Ele utiliza plugins para suportar várias linguagens e stacks, proporcionando uma experiência muito mais prática e unificada para desenvolvedores que trabalham em múltiplos projetos. 🚀

Por que vale a pena testar o asdf?   
✅ Simplifica o gerenciamento de versões.    
✅ Funciona com várias linguagens e ferramentas em um só lugar.    
✅ Ideal para quem lida com múltiplas stacks de forma ágil.    

🌟 Quer organizar suas dependências de maneira eficiente e prática? Confira meu tutorial completo onde explico tudo em detalhes! 👇

👉 Leia o post completo aqui: https://dev.to/adrianoavelino/asdf-gerenciando-versoes-de-linguagens-e-ferramentas-num-lugar-so-1lmh

### Múltiplos Schemas no Mesmo Tópico: Como Isso É Possível?
Você já imaginou usar mais de um schema Avro em um único tópico? Embora não seja algo tão comum, essa abordagem funciona — e funciona muito bem em diversos cenários! 🚀 Mas como isso é possível?

A resposta está na estratégia de nomeação de subjects no Schema Registry, mais especificamente com a TopicRecordNameStrategy.

👉 O que é o subject?    
É o local onde as versões dos seus arquivos Avro são armazenadas no Schema Registry. A estratégia escolhida define como esse subject será nomeado, e com a TopicRecordNameStrategy, você consegue configurar múltiplos schemas em um único tópico de forma eficiente.

Exemplo Prático    
Para ilustrar, neste post você vai encontrar:    
1️⃣ O problema gerado ao usar a estratégia padrão.    
2️⃣ A solução com a TopicRecordNameStrategy.    

Tudo explicado de forma clara, sem a necessidade de código! Vamos usar comandos simples na linha de comando para testar a configuração e entender a teoria por trás.

Se essa ideia é nova para você, não se preocupe: com o conceito certo e uma abordagem prática, você pode implementar essa solução facilmente!

Pronto para mergulhar nesse conceito e transformar sua abordagem? Vamos lá! 🙌
