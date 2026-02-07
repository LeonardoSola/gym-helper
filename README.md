# 🏋️ Gym Helper

Um aplicativo Flutter para ajudar no treino na academia, com cronômetro de descanso inteligente e contador de séries e repetições.

## 📱 Sobre o Projeto

O **Gym Helper** é um aplicativo mobile desenvolvido em Flutter que auxilia atletas e frequentadores de academia a otimizar seus treinos através do controle preciso de intervalos de descanso e acompanhamento de séries e repetições. O app funciona 100% offline, garantindo privacidade total e funcionamento mesmo sem conexão com a internet.

## ✨ Funcionalidades

- ⏱️ **Cronômetro de Descanso Inteligente**
  - Intervalos pré-definidos: 30s, 40s e 50s
  - Modo personalizado para criar seu próprio intervalo (10s a 99s)
  - Notificação por vibração quando o tempo acaba
  - Tela sempre ativa durante o uso

- 📊 **Contador de Séries e Repetições**
  - Acompanhe quantas séries você já completou
  - Conte suas repetições em tempo real
  - Função desfazer para corrigir contagens acidentais

- 🔄 **Modo Auto-Play**
  - Reinicia o cronômetro automaticamente após cada intervalo
  - Ideal para treinos intensos e circuitos

- 📱 **Otimizado para Wear OS**
  - Use diretamente no seu smartwatch durante o treino

- 🔒 **Privacidade Total**
  - Funciona 100% offline
  - Não coleta dados pessoais
  - Sem anúncios

## 🛠️ Tecnologias Utilizadas

- **Flutter** - Framework multiplataforma
- **Dart** - Linguagem de programação
- **Packages:**
  - `intl` - Formatação de datas e números
  - `vibration` - Notificações por vibração
  - `wakelock_plus` - Manter tela ativa

## 📋 Requisitos

- Flutter SDK >= 3.4.3
- Dart SDK >= 3.4.3
- Android SDK 21+ (Android 5.0+)
- Wear OS (opcional, para uso em smartwatch)

## 🚀 Instalação

1. Clone o repositório:
```bash
git clone https://github.com/LeonardoSola/gym-helper.git
cd gym-helper
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute o aplicativo:
```bash
flutter run
```

## 📖 Tutorial de Uso

### Primeira Tela — Escolha do Tempo de Descanso

Na primeira tela, você escolhe o tempo de descanso entre uma série e outra.

- **Opções pré-definidas:** Botões rápidos para 30s, 40s e 50s
- **Ajuste manual:** Toque no ícone de cronômetro para configurar um tempo personalizado
  - **Tempo mínimo:** 10 segundos
  - **Tempo máximo:** 99 segundos
  - A seleção do tempo funciona com um gesto de giro para cima ou para baixo, semelhante a um cadeado ou seletor rotativo

Após escolher o tempo, basta tocar em **Play** para iniciar.

### Tela Principal do App

#### Contador Central

- No centro da tela fica o **contador de séries**
- Ao tocar em qualquer área da tela (exceto nos botões), o app:
  - Entra em **modo descanso**
  - Incrementa automaticamente o contador de séries

#### Modo Descanso (REST)

Quando entra em descanso:

- O texto **REST** aparece no topo
- Inicia uma **contagem regressiva** com o tempo configurado
- Ao finalizar:
  - O celular **vibra**
  - A tela fica **verde**
  - Basta tocar na tela para voltar ao modo exercício (**GO**)

#### Modo Exercício (GO)

- Indicado pelo texto **GO**
- Representa o tempo ativo do exercício
- O usuário controla manualmente quando iniciar o próximo descanso tocando na tela

### Controles Adicionais

#### 🔁 Loop (bolinha superior direita)

- Quando ativado:
  - Ao finalizar o descanso, o app **não fica verde**
  - Apenas vibra e **retorna automaticamente ao modo exercício**
- Ideal para treinos com ritmo contínuo

#### ↩️ Voltar (bolinha inferior direita)

- Retorna para o estado anterior:
  - Se estava em exercício → volta para exercício
  - Se estava em descanso → volta para descanso
- Útil para corrigir toques acidentais

#### 🔢 Contador de Exercícios (bolinha esquerda)

- Exibe o **contador de exercícios**
- Ao tocar:
  - Incrementa o número de exercícios em **+1**
  - Reseta automaticamente o contador de séries

## 📁 Estrutura do Projeto

```
gym-helper/
├── android/              # Configurações Android
├── lib/
│   ├── main.dart         # Ponto de entrada do app
│   ├── pages/            # Telas do aplicativo
│   │   ├── home_page.dart
│   │   └── counter_page.dart
│   ├── widgets/          # Componentes reutilizáveis
│   │   ├── circle_button.dart
│   │   ├── series_button.dart
│   │   ├── top_clock.dart
│   │   └── ...
│   └── utils/            # Utilitários
│       └── vibration_helper.dart
├── pubspec.yaml          # Dependências do projeto
└── README.md
```

## 🏗️ Build para Produção

### Android

```bash
flutter build apk --release
```

### Android App Bundle (para Google Play)

```bash
flutter build appbundle --release
```

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 🤝 Contribuindo

Contribuições são sempre bem-vindas! Sinta-se à vontade para:

1. Fazer um Fork do projeto
2. Criar uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abrir um Pull Request

## 📞 Contato

Para dúvidas, sugestões ou problemas, abra uma [issue](https://github.com/LeonardoSola/gym-helper/issues) no repositório.

---

Desenvolvido com ❤️ usando Flutter
