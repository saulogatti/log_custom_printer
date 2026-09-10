# AI Instructions — Dart (`log_custom_printer` library)

This repository is a **Dart library** (no Flutter dependency in `pubspec`).
The Flutter visual console moved to a **separate package**; UI rules below apply to Flutter apps/packages that consume this library, not to the core in `lib/`.

> Important: also follow `.github/copilot-instructions.md`.

## Mandatory rules

1. **Never duplicate code.**
2. **Avoid large widgets.**
3. **Keep reusable widgets in separate files.**
4. **Evolve toward Clean Architecture incrementally.**
5. **Use BLoC/Cubit for complex screen logic/state.**

## Architecture guidelines

- Organize by layers when applicable:
  - **Presentation** (widgets/screens + bloc/cubit)
  - **Domain** (rules, entities, use cases)
  - **Data** (repositories, data sources, DTOs)
  - **Core** (shared utilities)
- Keep low coupling and clear responsibilities.
- Prefer composition over inheritance.
- Keep dependencies pointing inward.

## Dart rules

- Follow Effective Dart and `analysis_options.yaml`.
- Use clear naming.
- Keep code simple and focused.
- Handle errors explicitly.
- Preserve strong null safety; avoid unchecked `!`.
- Document public APIs with `///` when meaningful.

## Flutter/UI rules

- Keep widgets small and render-focused.
- Extract private widgets to simplify `build()`.
- Use lazy list builders for long lists.
- Avoid heavy work inside `build()`.
- Prefer `const` where possible.

## State and data flow

- For loading/multi-state/pagination/filter/error/non-trivial screens: **use BLoC/Cubit**.
- Use explicit states (`initial/loading/success/error`).
- UI renders state and triggers intents only.

## Testing

- Follow Arrange-Act-Assert.
- Prioritize domain and bloc/cubit tests for critical logic.
- In UI tests, validate render output by state.
- Prefer fakes/stubs over mocks when viable.

## Logging and observability

- Do not use loose `print` calls.
- Use this project’s logging strategy.
- Prefer structured logging where applicable.

## Code generation

- Do not edit `*.g.dart` manually.
- Regenerate code with `build_runner` after `json_serializable` model changes.

## Dependencies

- Add external packages only with clear benefit.
- Prefer existing project solutions first.

## Language requirement

- Write documentation, comments, and AI responses in **English**.

## Final checklist

- Code duplication removed?
- Large widgets split?
- Reusable components extracted?
- Business logic outside UI?
- Complex flows handled with BLoC/Cubit?
