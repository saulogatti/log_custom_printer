import 'package:log_custom_printer/src/console_view/domain/models/console_options.dart';

/// Repositório de opções de configuração do console visual.
///
/// Define o contrato para leitura e persistência das preferências do
/// [ConsoleView] (filtro temporal, opção selecionada, etc.).
/// A implementação padrão é [OptionsRepositoryImpl].
abstract interface class IOptionsRepository {
  /// Retorna as opções de configuração atualmente salvas.
  Future<ConsoleOptions> getCurrentOptions();

  /// Persiste o intervalo de data/hora selecionado para o filtro temporal.
  ///
  /// [start] e [end] são timestamps em milissegundos desde a época Unix.
  /// Valores iguais a zero indicam ausência de intervalo.
  Future<void> selectDateTimeRange(int start, int end);

  /// Persiste a [option] selecionada pelo usuário.
  Future<void> selectOption(OptionItem option);

  /// Habilita ou desabilita o filtro temporal conforme [enabled].
  Future<void> setDateTimeFilterEnabled(bool enabled);
}
