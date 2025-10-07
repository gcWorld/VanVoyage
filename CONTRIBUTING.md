# Contributing to VanVoyage

Thank you for your interest in contributing to VanVoyage!

## Development Process

1. **Fork and Clone**: Fork the repository and clone it locally
2. **Create Branch**: Create a feature branch from `main`
3. **Make Changes**: Implement your changes following the project architecture
4. **Test**: Ensure all tests pass and add tests for new features
5. **Format**: Run `dart format .` to format your code
6. **Analyze**: Run `flutter analyze` to check for issues
7. **Commit**: Write clear, descriptive commit messages
8. **Push**: Push your changes to your fork
9. **Pull Request**: Open a PR with a clear description of changes

## Code Style

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use the provided `analysis_options.yaml` settings
- Run `dart format .` before committing
- Ensure `flutter analyze` passes without errors

## Architecture

Please review the architecture documentation in `/docs/architecture/` before making significant changes:
- Follow the established patterns (BLoC + Riverpod)
- Use the defined directory structure
- Keep business logic separate from UI code

## Testing

- Write tests for new features
- Ensure existing tests pass
- Aim for good test coverage
- Use mockito for mocking dependencies

## Commit Messages

Use clear, descriptive commit messages:
- `feat: Add new feature`
- `fix: Fix bug in component`
- `docs: Update documentation`
- `test: Add tests for feature`
- `refactor: Refactor component`

## Questions?

Feel free to open an issue for questions or discussions about the project.
