import 'package:http/http.dart' as http;

import 'dart:convert';
import 'dart:async';

import 'package:peliculas/src/models/pelicula_model.dart';
import 'package:peliculas/src/models/actores_model.dart';

class PeliculasProvider {
  String _apiKey = '596344af8785289c873d6d4903ad2a61';
  String _url = 'api.themoviedb.org'; // direccion authority
  String _language = 'es-ES';

  bool _cargando = false;

  int _popularesPage = 0;

  List<Pelicula> _populares = [];

// tuberia de streamController variable privada
  final _popularesStreamController =
      StreamController<List<Pelicula>>.broadcast();

//flujo de entrada getter
  Function(List<Pelicula>) get popularesSink =>
      _popularesStreamController.sink.add;
//flujo de salida
  Stream<List<Pelicula>> get popularesStream =>
      _popularesStreamController.stream;

  void disposeStreams() {
    _popularesStreamController.close();
  }

  Future<List<Pelicula>> _procesarRespuesta(url) async {
    final resp = await http.get(url);
    final decodeData = json.decode(resp.body);
    final peliculas = new Peliculas.fromJsonList(decodeData['results']);
    return peliculas.items;
  }

// hace una peticion a los servicios de la pagina y regresa una lista de peliculas segun el modelo
  Future<List<Pelicula>> getEnCines() async {
    //con esto formo la direccion seccionada
    // '3/movie/now_playing' path sin los argumentos
    final url = Uri.https(_url, '3/movie/now_playing',
        {'api_key': _apiKey, 'language': _language});

    // peticion http propiamente
    //final resp = await http.get(url);
    //transforma la respuesta en un mapa(json de la pagina)
    //final decodeData = json.decode(resp.body);

    // aca se envia el json de la pagina al modelo
    //final peliculas = new Peliculas.fromJsonList(decodeData['results']);

    //print(peliculas.items[1].title);
    //print(decodeData['results']);
    //return peliculas.items;

    return await _procesarRespuesta(url);
  }

  Future<List<Pelicula>> getPopulares() async {
    if (_cargando) return [];

    _cargando = true;

    _popularesPage++;

    final url = Uri.https(
      _url,
      '3/movie/popular',
      {
        'api_key': _apiKey,
        'language': _language,
        'page': _popularesPage.toString()
      },
    );

    final resp = await _procesarRespuesta(url);

    _populares.addAll(resp);

    popularesSink(_populares);

    _cargando = false;
    return resp;
  }

  Future<List<Actor>> getCast(String peliId) async {
    final url = Uri.https(_url, '3/movie/$peliId/credits',
        {'api_key': _apiKey, 'language': _language});

    final resp = await http.get(url);
    final decodedData = json.decode(resp.body);
    // realiza una cast a la clase Cast; instancia de Cast
    final cast = new Cast.fromJsonList(decodedData['cast']);

    return cast.actores;
  }

  Future<List<Pelicula>> buscarPelicula(String query) async {
    //con esto formo la direccion seccionada
    // '3/movie/now_playing' path sin los argumentos
    final url = Uri.https(_url, '3/search/movie',
        {'api_key': _apiKey, 'language': _language, 'query': query});

    // peticion http propiamente
    //final resp = await http.get(url);
    //transforma la respuesta en un mapa(json de la pagina)
    //final decodeData = json.decode(resp.body);

    // aca se envia el json de la pagina al modelo
    //final peliculas = new Peliculas.fromJsonList(decodeData['results']);

    //print(peliculas.items[1].title);
    //print(decodeData['results']);
    //return peliculas.items;

    return await _procesarRespuesta(url);
  }
}
