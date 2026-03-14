// import 'package:flutter/material.dart';
// import 'package:log_custom_printer/src/widgets/console_widget.dart';

// class ConsoleOverlayManager {
//   static OverlayEntry? _overlayEntry;

//   /// Oculta o overlay do console caso esteja em execução.
//   static void hideOverlay() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//   }

//   /// Exibe o overlay do console sobrepondo a rota ativa.
//   static void showOverlay(BuildContext context) {
//     if (_overlayEntry != null) return;

//     _overlayEntry = OverlayEntry(
//       builder: (context) {
//         // Envolvemos todo o construto em `IgnorePointer`.
//         // Isso garante que eventos físicos de toque atravessem o console
//         // e cheguem na aplicação abaixo de forma ininterrupta.
//         return IgnorePointer(
//           ignoring: true,
//           child: SafeArea(
//             child: Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 margin: const EdgeInsets.all(16.0),
//                 height: 250.0,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8.0),
//                   boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10.0, offset: Offset(0, 4))],
//                 ),
//                 child: Material(
//                   color: Colors.transparent,
//                   clipBehavior: Clip.antiAlias,
//                   borderRadius: const BorderRadius.all(Radius.circular(8.0)),
//                   // TODO mudar para o ValueListenable real do console
//                   child: ConsoleWidget(valueListenable: ValueNotifier<List<String>>(const [])),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );

//     Overlay.of(context).insert(_overlayEntry!);
//   }
// }
