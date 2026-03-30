import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/message_repository.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/console_bloc.dart';
import 'package:log_custom_printer/src/domain/i_logger_cache_repository.dart';

import 'console_view.dart';

class ConsoleOverlayManager {
  static OverlayEntry? _overlayEntry;

  static OverlayEntry? _customOverlayEntry;

  // Define a posição inicial na tela
  static final ValueNotifier<Offset> _position = ValueNotifier(
    const Offset(100, 100),
  );
  static final ValueNotifier<Size> _sizeListenable = ValueNotifier(
    const Size(400, 260),
  );

  /// Remove o overlay criado por [show] (janela arrastável com [ConsoleView]).
  ///
  /// Não afeta o overlay de [showOverlay]; para esse use [hideConsoleOverlayManager].
  static void hide() {
    _customOverlayEntry?.remove();
    _customOverlayEntry = null;
  }

  /// Remove o overlay criado por [showOverlay] (barra inferior com [ConsoleView]).
  ///
  /// Não afeta o overlay de [show]; para esse use [hide].
  static void hideConsoleOverlayManager() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  static void setSize(Size size) {
    assert(size.width > 0 && size.height > 0, 'Size must be greater than 0');
    _sizeListenable.value = size;
  }

  static void show(
    BuildContext context,
    MessageRepository messageRepository,
    ILoggerCacheRepository loggerCacheRepository,
    Size size,
  ) {
    setSize(size);
    // Evita abrir dois overlays e dar dor de cabeça
    if (_customOverlayEntry != null) return;

    _customOverlayEntry = OverlayEntry(
      canSizeOverlay: true,
      builder: (context) {
        return ValueListenableBuilder<Offset>(
          valueListenable: _position,
          builder: (context, offset, child) {
            return Positioned(
              left: offset.dx,
              top: offset.dy,
              child: GestureDetector(
                // O segredo do drag está aqui
                onPanUpdate: (details) {
                  _position.value += details.delta;
                },
                child: Material(
                  color: Colors.transparent,
                  elevation: 0,
                  child: ValueListenableBuilder(
                    valueListenable: _sizeListenable,
                    builder: (context, size, child) {
                      return Container(
                        width: size.width,
                        height: size.height,
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: BlocProvider(
                          create: (context) => ConsoleBloc(
                            messageRepository: messageRepository,
                            loggerCacheRepository: loggerCacheRepository,
                          ),
                          child: const ConsoleView(onClose: hide),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    Overlay.of(context).insert(_customOverlayEntry!);
  }

  /// Exibe o overlay do console sobrepondo a rota ativa.
  static void showOverlay(
    BuildContext context,
    MessageRepository messageRepository,
    ILoggerCacheRepository loggerCacheRepository, [
    bool draggable = false,
  ]) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      canSizeOverlay: true,
      builder: (context) {
        // Envolvemos todo o construto em `IgnorePointer`.
        // Isso garante que eventos físicos de toque atravessem o console
        // e cheguem na aplicação abaixo de forma ininterrupta.
        return IgnorePointer(
          ignoring: !draggable, // Se for arrastável, não ignoramos os eventos
          child: SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(16.0),
                height: 250.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 10.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  clipBehavior: Clip.antiAlias,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),

                  child: BlocProvider(
                    create: (_) => ConsoleBloc(
                      messageRepository: messageRepository,
                      loggerCacheRepository: loggerCacheRepository,
                    ),
                    child: const ConsoleView(
                      onClose: hideConsoleOverlayManager,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }
}
