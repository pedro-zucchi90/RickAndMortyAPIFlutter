# Rick and Morty API Explorer

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)

**Uma aplicação Flutter completa para explorar o universo de Rick and Morty através da API oficial**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![API](https://img.shields.io/badge/API-Rick%20and%20Morty-green.svg)](https://rickandmortyapi.com/)

</div>

---

## Sobre o Projeto

O **Rick and Morty API Explorer** é uma aplicação móvel desenvolvida em Flutter que permite aos usuários explorar de forma interativa e intuitiva todo o universo da série Rick and Morty. A aplicação consome a [Rick and Morty API](https://rickandmortyapi.com/) para fornecer acesso completo aos personagens, episódios e localizações da série.

### Características Principais

- **Exploração de Personagens**: Visualize todos os personagens com imagens, status, espécie e informações detalhadas
- **Catálogo de Episódios**: Navegue por todos os episódios com informações sobre data de exibição e personagens participantes
- **Mapa de Localizações**: Explore diferentes dimensões e locais do universo Rick and Morty
- **Interface Responsiva**: Design moderno e intuitivo para Android e iOS
- **Navegação Fluida**: Sistema de navegação com telas de detalhes para cada categoria
- **Integração com API**: Consumo eficiente da API oficial com tratamento de erros

---

## Arquitetura do Projeto

### Estrutura de Diretórios

```
lib/
├── main.dart                 # Ponto de entrada da aplicação
├── models/                   # Modelos de dados
│   ├── characterModels.dart  # Modelo para personagens
│   ├── episodesModel.dart    # Modelo para episódios
│   └── locationModel.dart    # Modelo para localizações
├── services/                 # Serviços de API
│   └── service.dart          # Serviços para consumir a API
├── characters/               # Telas relacionadas a personagens
│   └── charactersList.dart   # Lista e detalhes de personagens
├── episodes/                 # Telas relacionadas a episódios
│   └── episodesList.dart     # Lista e detalhes de episódios
└── location/                 # Telas relacionadas a localizações
    └── locationList.dart     # Lista e detalhes de localizações
```

### Padrões de Desenvolvimento

- **Arquitetura**: Padrão MVC (Model-View-Controller)
- **Gerenciamento de Estado**: StatefulWidget para controle de estado local
- **Consumo de API**: Serviços dedicados com tratamento de erros
- **Navegação**: Navigator 1.0 com MaterialPageRoute
- **UI/UX**: Material Design com componentes customizados

---

## Tecnologias Utilizadas

### Core Framework
- **Flutter SDK**: ^3.8.1
- **Dart**: Linguagem de programação principal
- **Material Design**: Sistema de design do Google

### Dependências Principais
- **http**: ^1.5.0 - Para requisições HTTP à API
- **cupertino_icons**: ^1.0.8 - Ícones do iOS
- **flutter_lints**: ^5.0.0 - Análise estática de código

### Plataformas Suportadas
- **Android** (API 21+)
- **iOS** (iOS 11.0+)
- **Web** (Chrome, Firefox, Safari)
- **Windows** (Windows 10+)
- **macOS** (macOS 10.14+)
- **Linux** (Ubuntu 18.04+)

---

## Funcionalidades Detalhadas

### Módulo de Personagens

**Tela Principal**: Lista paginada de todos os personagens
- Exibição de imagem, nome e informações básicas
- Cards interativos com design responsivo
- Indicador de carregamento durante requisições

**Tela de Detalhes**: Informações completas do personagem
- Imagem em alta resolução
- Status (Vivo, Morto, Desconhecido)
- Espécie e tipo
- Gênero
- Origem e localização atual
- Lista de episódios em que aparece
- Metadados (URL da API, data de criação)

### Módulo de Episódios

**Tela Principal**: Catálogo completo de episódios
- Lista organizada por temporada e episódio
- Informações de data de exibição
- Navegação intuitiva

**Tela de Detalhes**: Informações detalhadas do episódio
- Nome e código do episódio
- Data de exibição original
- Grid de personagens participantes com imagens
- Carregamento assíncrono de dados de personagens
- Tratamento de erros para personagens não encontrados

### Módulo de Localizações

**Tela Principal**: Mapa de localizações do universo
- Lista de todos os locais conhecidos
- Informações de tipo e dimensão
- Interface limpa e organizada

**Tela de Detalhes**: Detalhes completos da localização
- Nome, tipo e dimensão
- Grid de residentes com imagens
- Carregamento dinâmico de dados de residentes
- Sistema de fallback para dados indisponíveis

---

## Modelos de Dados

### CharacterModel
```dart
class CharacterModel {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final Origin origin;
  final Location location;
  final String image;
  final List<String> episode;
  final String url;
  final String created;
}
```

### EpisodesModel
```dart
class EpisodesModel {
  final int id;
  final String name;
  final String air_date;
  final String episode;
  final List<String> characters;
  final String url;
  final String created;
}
```

### LocationModel
```dart
class LocationModel {
  final int id;
  final String name;
  final String type;
  final String dimension;
  final List<String> residents;
  final String url;
  final String created;
}
```

---

## Serviços de API

### APIService
- **Endpoint**: `https://rickandmortyapi.com/api/character`
- **Método**: `fetchCharacters()`
- **Retorno**: `Future<List<CharacterModel>>`
- **Tratamento de Erros**: Exceções personalizadas para falhas de rede

### EpisodeService
- **Endpoint**: `https://rickandmortyapi.com/api/episode`
- **Método**: `fetchEpisodes()`
- **Retorno**: `Future<List<EpisodesModel>>`
- **Funcionalidades**: Carregamento de episódios com metadados

### LocationService
- **Endpoint**: `https://rickandmortyapi.com/api/location`
- **Método**: `fetchLocations()`
- **Retorno**: `Future<List<LocationModel>>`
- **Integração**: Dados de localizações e residentes

---

## Como Executar o Projeto

### Pré-requisitos
- Flutter SDK 3.8.1 ou superior
- Dart SDK 3.0.0 ou superior
- Android Studio / VS Code com extensão Flutter
- Git

### Instalação

1. **Clone o repositório**
```bash
git clone https://github.com/seu-usuario/rickandmorty-api-explorer.git
cd rickandmorty-api-explorer
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Execute a aplicação**
```bash
# Para Android
flutter run

# Para iOS
flutter run -d ios

# Para Web
flutter run -d web

# Para Windows
flutter run -d windows
```

### Build para Produção

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

---

## Design e UX

### Paleta de Cores
- **Primária**: Azul Material Design (#2196F3)
- **Secundária**: Verde (#4CAF50)
- **Acentos**: Laranja (#FF9800)
- **Neutros**: Cinza (#757575), Branco (#FFFFFF)

### Componentes UI
- **Cards**: Design elevado com sombras sutis
- **Botões**: Estilo Material com bordas arredondadas
- **Imagens**: Carregamento otimizado com fallbacks
- **Loading**: Indicadores de progresso nativos
- **Navegação**: Transições suaves entre telas

### Responsividade
- **Mobile First**: Design otimizado para dispositivos móveis
- **Tablet**: Layout adaptativo para telas maiores
- **Desktop**: Interface expandida para computadores

---

## Funcionalidades Técnicas

### Gerenciamento de Estado
- **StatefulWidget**: Para componentes que precisam de estado
- **FutureBuilder**: Para carregamento assíncrono de dados
- **setState()**: Para atualizações de interface

### Tratamento de Erros
- **Try-Catch**: Para requisições HTTP
- **Fallbacks**: Dados padrão quando API falha
- **Mensagens**: Feedback claro para o usuário

### Performance
- **Lazy Loading**: Carregamento sob demanda
- **Image Caching**: Cache automático de imagens
- **Memory Management**: Limpeza adequada de recursos

---

## Métricas e Estatísticas

### Dados da API
- **Personagens**: 800+ personagens únicos
- **Episódios**: 50+ episódios organizados por temporada
- **Localizações**: 100+ locais em diferentes dimensões
- **Imagens**: Todas as imagens em alta resolução

### Performance
- **Tempo de Carregamento**: < 2 segundos para dados iniciais
- **Memória**: Otimizada para dispositivos de baixo custo
- **Bateria**: Consumo eficiente de recursos

---

## Testes

### Testes Unitários
```bash
flutter test
```

### Testes de Widget
```bash
flutter test test/widget_test.dart
```

### Testes de Integração
```bash
flutter drive --target=test_driver/app.dart
```

---

## Roadmap Futuro

### Versão 2.0
- [ ] Sistema de favoritos
- [ ] Busca avançada com filtros
- [ ] Modo offline com cache local
- [ ] Notificações push
- [ ] Temas personalizáveis

### Versão 2.1
- [ ] Compartilhamento de personagens
- [ ] Estatísticas de visualização
- [ ] Integração com redes sociais
- [ ] Widgets para tela inicial

### Versão 3.0
- [ ] Realidade aumentada
- [ ] Jogos interativos
- [ ] Chat com IA do Rick
- [ ] Modo multijogador

---

## Contribuição

Contribuições são sempre bem-vindas! Para contribuir:

1. **Fork** o projeto
2. **Crie** uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. **Push** para a branch (`git push origin feature/AmazingFeature`)
5. **Abra** um Pull Request

### Padrões de Código
- Siga as convenções do Dart/Flutter
- Use `flutter analyze` para verificar o código
- Escreva testes para novas funcionalidades
- Documente funções complexas

---

## Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## Desenvolvedor

**Desenvolvido por Pedro Luiz Chaves Zucchi**

- Email: pedro@zucchi.dev.br
- LinkedIn: [linkedin.com/in/seu-perfil](https://www.linkedin.com/in/pedro-zucchi-52b50132b/)
- GitHub: [github.com/pedro-zucchi90](https://github.com/pedro-zucchi90)

---

## Agradecimentos

- **Rick and Morty API** - Pela API gratuita e bem documentada
- **Flutter Team** - Pelo framework incrível
- **Material Design** - Pelo sistema de design
- **Comunidade Flutter** - Pelo suporte e recursos

---

<div align="center">

**Se este projeto te ajudou, considere dar uma estrela!**

![Rick and Morty](https://media.giphy.com/media/3o7btPCcdNniyf0ArS/giphy.gif)

*"Wubba Lubba Dub Dub!"* - Rick Sanchez

</div>
