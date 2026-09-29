# Komodo Persistence Layer

This package provides the functionality to persist data to storage and retrieve it.

<!-- ## Features

TODO: List what your package can do. Maybe include images, gifs, or videos. -->

<!-- ## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package. -->

## Usage

### Create

```dart
import 'package:komodo_persistence_layer/komodo_persistence_layer.dart';

Future<void> main() async {
    final PersistenceProvider<String, Coin> coinsProvider = HiveBoxProvider<String, Coin>();
    final Coin coin = Coin(
        id: 'bitcoin',
        fname: 'Bitcoin',
    );
    await coinsProvider.insert(coin);
}
```

### Read

```dart
import 'package:komodo_persistence_layer/komodo_persistence_layer.dart';

Future<void> main() async {
    final PersistenceProvider<String, Coin> coinsProvider = HiveBoxProvider<String, Coin>();
    final List<Coin> coins = await coinsProvider.getAll();
    for (final coin in coins) {
        print(coin.fname);
    }
}
```

<!-- ## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more. -->
