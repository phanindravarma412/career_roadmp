import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/reminders.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/sync_status.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _time(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return '$hour12:${m.toString().padLeft(2, '0')} ${h < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _Header('Reminders'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Daily study reminder'),
            subtitle: Text(
              kIsWeb
                  ? 'Works on the Android app only'
                  : 'Plus a nudge at ${_time(Reminders.streakNudgeHour * 60 + Reminders.streakNudgeMinute)} '
                        'if your streak is at risk',
            ),
            value: state.reminderOn,
            onChanged: (v) async {
              final granted = await state.setReminder(on: v);
              if (!granted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Allow notifications for Roadmap in Android settings.')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.alarm_rounded),
            title: const Text('Reminder time'),
            trailing: Text(_time(state.reminderMinutes), style: const TextStyle(fontWeight: FontWeight.w600)),
            enabled: state.reminderOn,
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                  hour: state.reminderMinutes ~/ 60,
                  minute: state.reminderMinutes % 60,
                ),
              );
              if (picked != null) {
                await state.setReminder(on: true, minutes: picked.hour * 60 + picked.minute);
              }
            },
          ),
          _Header('GitHub sync'),
          const SyncStatusLine(),
          ListTile(
            leading: const Icon(Icons.cloud_sync_outlined),
            title: const Text('Sync now'),
            subtitle: const Text('Also happens when you open the app or pull down on Today / Reviews'),
            trailing: state.syncing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4))
                : null,
            onTap: () => syncWithFeedback(context),
          ),
          ListTile(
            leading: const Icon(Icons.source_outlined),
            title: const Text('Repository'),
            subtitle: Text('${state.repo} · ${state.branch}'),
            onTap: () async {
              final repoCtrl = TextEditingController(text: state.repo);
              final branchCtrl = TextEditingController(text: state.branch);
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('GitHub repository'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: repoCtrl, decoration: const InputDecoration(labelText: 'owner/name')),
                      TextField(controller: branchCtrl, decoration: const InputDecoration(labelText: 'Branch')),
                      const SizedBox(height: 8),
                      const Text('Must be a public repo.', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                await state.setRepo(repoCtrl.text, branchCtrl.text);
                if (context.mounted) await syncWithFeedback(context);
              }
            },
          ),
          _Header('Schedule'),
          ListTile(
            leading: const Icon(Icons.event_rounded),
            title: const Text('Day 1 date'),
            subtitle: const Text('Used for "behind / ahead of schedule"'),
            trailing: Text(shortDate(state.startDate), style: const TextStyle(fontWeight: FontWeight.w600)),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: state.startDate,
                firstDate: DateTime(2026),
                lastDate: DateTime(2028),
              );
              if (picked != null) await state.setStartDate(picked);
            },
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt_rounded),
            title: const Text('Re-plan from today'),
            subtitle: Text('Makes today ${state.currentDay.title}. Ticked tasks stay.'),
            onTap: () async {
              await state.replanFromToday();
              messenger.showSnackBar(
                SnackBar(content: Text('Day 1 is now ${shortDate(state.startDate)}.')),
              );
            },
          ),
          _Header('Motivation'),
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Why I\'m doing this'),
            subtitle: Text(state.goal),
            onTap: () async {
              final controller = TextEditingController(text: state.goal);
              final value = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Your goal'),
                  content: TextField(controller: controller, maxLines: 3, autofocus: true),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, controller.text),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
              if (value != null) await state.setGoal(value);
            },
          ),
          _Header('Backup'),
          ListTile(
            leading: const Icon(Icons.copy_rounded),
            title: const Text('Copy backup'),
            subtitle: const Text('Progress lives only on this phone. Paste the backup somewhere safe.'),
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: state.exportBackup()));
              messenger.showSnackBar(const SnackBar(content: Text('Backup copied to clipboard.')));
            },
          ),
          ListTile(
            leading: const Icon(Icons.paste_rounded),
            title: const Text('Restore from clipboard'),
            onTap: () async {
              final data = await Clipboard.getData(Clipboard.kTextPlain);
              try {
                await state.importBackup(data?.text ?? '');
                messenger.showSnackBar(const SnackBar(content: Text('Progress restored.')));
              } catch (_) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Clipboard does not hold a Roadmap backup.')),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: scheme.error),
            title: Text('Reset all progress', style: TextStyle(color: scheme.error)),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset all progress?'),
                  content: const Text('Every ticked task and your streak history will be cleared. This cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: scheme.error),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
              if (ok == true) await state.resetProgress();
            },
          ),
          _Header('About'),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text('${state.plan.countedDays.length} days · ${state.totalTasks} tasks'),
            subtitle: const Text(
              'Plan, scores and check-ins come from the GitHub repo. Push changes and the app '
              'picks them up on the next sync. No re-install needed.',
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
