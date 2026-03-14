import 'package:flutter/material.dart';
import 'package:log_custom_printer/src/widgets/view/console_view.dart';

class ConsoleOverlayManager {
  static OverlayEntry? _overlayEntry;

  /// Oculta o overlay do console caso esteja em execução.
  static void hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Exibe o overlay do console sobrepondo a rota ativa.
  static void showOverlay(BuildContext context) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        // Envolvemos todo o construto em `IgnorePointer`.
        // Isso garante que eventos físicos de toque atravessem o console
        // e cheguem na aplicação abaixo de forma ininterrupta.
        return IgnorePointer(
          ignoring: true,
          child: SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(16.0),
                height: 250.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10.0, offset: Offset(0, 4))],
                ),
                child: Material(
                  color: Colors.transparent,
                  clipBehavior: Clip.antiAlias,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),

                  child: ConsoleView(),
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

class DraggableOverlay {
  OverlayEntry? _overlayEntry;
  // Define a posição inicial na tela
  final ValueNotifier<Offset> _position = ValueNotifier(const Offset(100, 100));

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void show(BuildContext context) {
    // Evita abrir dois overlays e dar dor de cabeça
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
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
                    width: 300,
                    height: 260,
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                    ),
                    child: ConsoleView(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }
}
