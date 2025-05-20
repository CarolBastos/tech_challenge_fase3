# Tech Challenge - fase 03

## Descrição

Este projeto é uma aplicação de gerenciamento financeiro desenvolvida em Flutter Mobile. O principal objetivo é fornecer aos usuários uma interface amigável para o gerenciamento de suas transações financeiras.

## Tecnologias Utilizadas

- Flutter
- Cloud Firestore
- Firebase Storage
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

## Metodologia utilizada

### Arquitetura

### Criptografia

Para a criptografia, foi utilizada a abordagem simétrica no client-side utilizando a biblioteca `encrypt` e `flutter_secure_storage` (esse último para armazenar a chave AES localmente no dispositivo) com a política de rotação de chaves. 
Foi considerada para o presente projeto, o nome e o e-mail do usuário como dados sensíveis. Os dados foram criptografados e enviados para o Firestore. Nesse caso, não foi necessário descriptografar os dados pois para utilizá-los no UI, eles estão vindo do Firebase Auth.

## Contribuições

- Anderson
- Carol Bastos
- Christian Martins
- Igor França
- Tayná Martins Ramos

Observação: Incluimos no link do Google Drive disponibilizado na plataforma da Fiap a versão release do apk para facilitar a instalação do app.
