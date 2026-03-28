import 'package:flutter/material.dart';
import 'package:log_custom_printer/src/view/console/console_view.dart';

class ConsoleOverlayManager {
  static OverlayEntry? _overlayEntry;

  static OverlayEntry? _customOverlayEntry;

  // Define a posição inicial na tela
  static final ValueNotifier<Offset> _position = ValueNotifier(
    const Offset(100, 100),
  );

  static void hide() {
    _customOverlayEntry?.remove();
    _customOverlayEntry = null;
  }

  /// Oculta o overlay do console caso esteja em execução.
  static void hideConsoleOverlayManager() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  static void show(BuildContext context) {
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
                  child: Container(
                    width: 400,
                    height: 260,
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
                    child: ConsoleView(onClose: hide),
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
  static void showOverlay(BuildContext context, [bool draggable = false]) {
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

                  child: ConsoleView(onClose: hideConsoleOverlayManager),
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
