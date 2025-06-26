# Gerenciamento de Sessão de Usuário no Smart Entregas

Este documento explica como implementar e utilizar o gerenciamento de sessão de usuário no aplicativo Smart Entregas, utilizando GetX, Firebase Authentication e Firestore.

## Visão Geral

O sistema de gerenciamento de sessão permite:

1. Manter a sessão do usuário ativa entre aberturas do aplicativo
2. Acessar dados do usuário de qualquer lugar do aplicativo
3. Direcionar o usuário para a tela correta com base em seu tipo (comercial ou logística)
4. Gerenciar o processo de login e logout de forma centralizada
5. Persistir o tipo de usuário no Firestore para acesso em múltiplos dispositivos

## Componentes Principais

### 1. UserSession

A classe `UserSession` é o componente central do gerenciamento de sessão. Ela:

- Armazena os dados do usuário de forma persistente usando GetStorage
- Observa mudanças no estado de autenticação do Firebase
- Fornece métodos para acessar e manipular os dados do usuário
- Implementa o padrão Singleton via GetX para acesso global
- Sincroniza dados com o Firestore

### 2. Integração com Firebase Authentication

O sistema utiliza o Firebase Authentication para:

- Autenticação por número de telefone e OTP
- Monitoramento do estado de autenticação
- Obtenção dos dados básicos do usuário

### 3. Integração com Firestore

O sistema utiliza o Firestore para:

- Armazenar o tipo de usuário (comercial ou logística)
- Permitir acesso aos dados do usuário em múltiplos dispositivos
- Manter os dados sincronizados entre dispositivos

### 4. Persistência de Dados Local

Os dados do usuário são persistidos localmente usando GetStorage, permitindo que:

- O aplicativo mantenha o usuário logado entre sessões
- Os dados do usuário sejam rapidamente acessíveis sem consultar o servidor

## Fluxo de Registro e Login

### Primeiro Login

1. O usuário insere seu número de telefone
2. Recebe e confirma o código OTP
3. O sistema verifica se o usuário já possui um tipo definido no Firestore
4. Se não possuir, é direcionado para a tela de registro para escolher seu tipo
5. O tipo escolhido é salvo no Firestore e no armazenamento local
6. O usuário é redirecionado para a tela correspondente ao seu tipo

### Logins Subsequentes

1. O usuário insere seu número de telefone
2. Recebe e confirma o código OTP
3. O sistema verifica que o usuário já possui um tipo definido no Firestore
4. O usuário é redirecionado diretamente para a tela correspondente ao seu tipo
5. O usuário não precisa passar pela tela de registro novamente

## Uso Básico

### Inicialização

O serviço é inicializado automaticamente no `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  Get.put(UserSession(), permanent: true);
  runApp(MyApp());
}
```

### Acessando o UserSession

Para acessar o serviço de qualquer lugar do aplicativo:

```dart
// Importar o serviço
import 'package:smart_entregas/services/user_session.dart';

// Acessar a instância (em qualquer lugar do app)
final userSession = UserSession.to;
// ou
final userSession = Get.find<UserSession>();
```

### Verificar Estado de Login

```dart
// Verificar se o usuário está logado
if (userSession.checkIsLoggedIn()) {
  // Usuário logado
} else {
  // Usuário não logado
}
```

### Verificar se o Tipo foi Definido

```dart
// Verificar se o usuário já definiu um tipo
if (userSession.hasDefinedUserType()) {
  // Usuário já tem um tipo definido
} else {
  // Usuário ainda não definiu um tipo
}
```

### Acessar Dados do Usuário

```dart
// Acessar dados diretamente
final uid = userSession.userData['uid'];
final phone = userSession.userData['phoneNumber'];

// Se precisar reagir a mudanças nos dados (com GetX)
Obx(() => Text('Olá, ${userSession.userData['name'] ?? 'Usuário'}'));
```

### Definir o Tipo de Usuário

```dart
// Para usuário do tipo comercial
await userSession.setUserType('commercial');

// Para usuário do tipo logística
await userSession.setUserType('logistic');
```

### Redirecionamento Baseado no Tipo de Usuário

```dart
// Redirecionar com base no tipo de usuário
userSession.redirectBasedOnUserType();
```

### Atualizar Dados do Usuário

```dart
// Atualizar dados do usuário (salva no Firestore também)
await userSession.updateUserData({
  'nome': 'João Silva',
  'email': 'joao@example.com',
  'endereco': 'Av. Paulista, 1000'
});
```

### Logout

```dart
// Fazer logout
await userSession.signOut();
```

## Estrutura do Firestore

A estrutura no Firestore é organizada da seguinte forma:

```
/users/{uid}/ -> Documento do usuário
  - userType: "commercial" ou "logistic"
  - createdAt: Timestamp da criação
  - [outros campos]: outros dados que você queira adicionar
```

## Segurança e Boas Práticas

1. **Dados Sensíveis**: Não armazene dados sensíveis (como tokens de acesso) no armazenamento local
2. **Validação de Dados**: Sempre valide os dados antes de salvá-los no Firestore
3. **Regras de Segurança**: Configure regras de segurança no Firestore para garantir que apenas o próprio usuário possa ler/escrever seus dados
4. **Tratamento de Erros**: Implemente tratamento de erros adequado para lidar com falhas na comunicação com o Firestore

## Resolução de Problemas

### Usuário Redirecionado para Tela de Registro Novamente

Verifique:

- Se o tipo de usuário está sendo salvo corretamente no Firestore
- Se o documento do usuário existe na collection "users"
- Se o campo "userType" contém um dos valores esperados: "commercial" ou "logistic"

### Problemas de Sincronização

Verifique:

- A conectividade com a internet
- Se o Firebase está inicializado corretamente
- Os logs para erros de comunicação com o Firestore

## Extensões Futuras

O sistema pode ser estendido para:

1. **Perfis mais detalhados**: Armazenar mais informações do usuário como nome, foto, etc.
2. **Histórico de sessões**: Registrar logins e atividades do usuário
3. **Preferências do usuário**: Configurações e preferências personalizadas
4. **Integração com outros serviços do Firebase**: Como Cloud Functions, Storage, etc.

## Conclusão

O sistema de gerenciamento de sessão com integração ao Firestore fornece uma maneira centralizada, robusta e eficiente de gerenciar a autenticação e os dados do usuário. A sincronização com o Firestore garante consistência entre dispositivos e uma experiência de usuário fluida no aplicativo Smart Entregas.
