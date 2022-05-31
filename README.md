# Menú Chapingo
Menú Chapingo es una aplicación para acceder el menú de los comedores central y campestre de 
la [Universidad Autónoma Chapingo.

## Instrucciones para compilar

### Android

```shell
flutter build apk --no-tree-shake-icons --split-per-abi
```

### Web

```shell
flutter build web --base-href "/web/"
```

Por el momento, solo funciona desde <https://menu-chapingo.firebaseapp.com/web/>