import 'package:bloc_tools/src/command_runner.dart';
import 'package:bloc_tools/src/commands/command.dart';
import 'package:bloc_tools/src/version.dart';
import 'package:mason/mason.dart' hide packageVersion;
import 'package:pub_updater/pub_updater.dart';

/// {@template update_command}
/// `bloc update` command which updates bloc_tools.
/// {@endtemplate}
class UpdateCommand extends BlocCommand {
  /// {@macro update_command}
  UpdateCommand({
    required PubUpdater pubUpdater,
    Logger? logger,
  })  : _pubUpdater = pubUpdater,
        super(logger: logger);

  final PubUpdater _pubUpdater;

  @override
  final String description = 'Update bloc_tools.';

  @override
  final String name = 'update';

  @override
  Future<int> run() async {
    final updateCheckDone = logger.progress('Checking for updates');
    late final String latestVersion;
    try {
      latestVersion = await _pubUpdater.getLatestVersion(packageName);
    } catch (error) {
      updateCheckDone();
      logger.err('$error');
      return ExitCode.software.code;
    }
    updateCheckDone('Checked for updates');

    final isUpToDate = packageVersion == latestVersion;
    if (isUpToDate) {
      logger.info('bloc is already at the latest version.');
      return ExitCode.success.code;
    }

    final updateDone = logger.progress('Updating to $latestVersion');
    try {
      await _pubUpdater.update(packageName: packageName);
    } catch (error) {
      updateDone();
      logger.err('$error');
      return ExitCode.software.code;
    }
    updateDone('Updated to $latestVersion');

    return ExitCode.success.code;
  }
}
