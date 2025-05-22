# Tech Challenge - fase 03

## Descrição

Este projeto é uma aplicação de gerenciamento financeiro desenvolvida em Flutter Mobile. O principal objetivo é fornecer aos usuários uma interface amigável para o gerenciamento de suas transações financeiras.

## Tecnologias Utilizadas

- Flutter
- Cloud Firestore
- Firebase Storageflut
- Redux
- Flutter Secure Storage
- Firebase Auth
- Encrypt

## Como Configurar e Executar

1. Clone o repositório:
   ```bash
   git clone git@github.com:CarolBastos/tech_challenge_fase3.git
   ```

2. Adicione o arquivo google-service.json:
    Coloque este arquivo no diretório android/app com as credenciais do Firebase.
    Por conter nossas credenciais, esse arquivo se encontra no link do Google Drive que disponibilizamos na plataforma da Fiap.

3. Liste emuladores disponíveis:
   ```bash
   flutter emulators
   ```
    Se não houver emuladores listados, será necessário criar um.

4. Inicie emulador escolhido:
   ```bash
   flutter emulators --launch <emulator_id>
   ```

5. Execute o projeto:
   ```bash
   flutter run
   ```

![Alt text da imagem](https://i.imgur.com/0gJNje4.png)

## Melhorias implementadas

### Separação modular da aplicação com pastas específicas:

- screens/ → Telas principais como Dashboard, Registro, Investimentos.
- redux/ → Gerenciamento de estado utilizando Redux.
- domain/ → 
- data/ → .
- utils/ → Utilitários, incluindo função de geração de chave criptográfica.

### Aplicação de State Management avançado:

- Implementado via Redux, promovendo modularidade e clareza na gestão de estado.

### Organização seguindo princípios de Clean Architecture:

lib/
├── data/
│   ├── api/
│   │   └── transaction_api.dart       # camada responsável pelas coleções do Firestore.
├── domain/
│   └── business/
│       ├── auth_workflow.dart         # Lógica de login, registro
│       └── transaction_workflow.dart  # Lógica de salvar/listar transações (cálculo do saldo, validações).
│   └── models/
│       ├── transaction.dart           # Entidade de transação
│       └── user.dart                  # Entidade de usuário
├── screens/
│   ├── components/                    # Componentes de UI (visuais e reutilizáveis)
│   │   ├── custom_button.dart
│   │   └── custom_text_field.dart
│   ├── dashboard_screen.dart
│   ├── investment_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── transactions_screen.dart
│   └── welcome_screen.dart
└── main.dart

### Criptografia

- Para a criptografia, foi utilizada a abordagem simétrica no client-side utilizando a biblioteca `encrypt` e `flutter_secure_storage` (esse último para armazenar a chave AES localmente no dispositivo) com a política de rotação de chaves. Foi considerada para o presente projeto, o nome e o e-mail do usuário como dados sensíveis. Os dados foram criptografados e enviados para o Firestore. Nesse caso, não foi necessário descriptografar os dados pois para utilizá-los no UI, eles estão vindo do Firebase Auth.

### Outros

- Aplicação de lazy loading de telas através de `routes.dart`.

## Contribuições

- Anderson
- Carol Bastos
- Christian Martins
- Igor França
- Tayná Martins Ramos