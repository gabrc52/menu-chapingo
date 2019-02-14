const data_url = 'menu-chapingo.firebaseapp.com';

const use_https = true;

const meses = <String>['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

const dias = <String>['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
const dias_completos = <String>['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];

class NoAlimentosException implements Exception {}

class Alimento {
  Alimento._();
  static const desayuno = 0;
  static const comida = 1;
  static const cena = 2;
  static const values = ['Desayuno', 'Comida', 'Cena'];
}

class Componente {
  Componente._();
  static const principal = 2;
  static const postre = 7;
}