import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

// To update OpenApi use: flutter pub run build_runner build --delete-conflicting-outputs
@Openapi(
    additionalProperties:
    AdditionalProperties(pubName: 'rickandmorty_api', pubAuthor: 'Rick and Morty'),
    inputSpecFile: 'assets/openapi/rickandmorty.yaml',
    generatorName: Generator.DART,
    outputDirectory: './openapi')
class OpenApi extends OpenapiGeneratorConfig {}