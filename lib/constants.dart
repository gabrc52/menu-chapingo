const data_url = 'menu-chapingo.firebaseapp.com';

const use_https = true;

const meses = <String>[
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic'
];

const dias = <String>['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

class NoAlimentosException implements Exception {}

class Alimento {
  static const desayuno = 0;
  static const comida = 1;
  static const cena = 2;
}