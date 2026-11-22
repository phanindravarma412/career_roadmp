import 'package:flutter/material.dart';

import '../models/plan.dart';
import '../state/app_state.dart';
import 'celebration.dart';
import 'common.dart';

/// A checkable task with its tag, folder chips and Input/Output details.
class TaskTile extends StatefulWidget {
  const TaskTile({super.key, required this.task});
  final PlanTask task;

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool _expanded = false;

  Future<void> _toggle(AppState state) async {
    final outcome = await state.toggle(widget.task);
    if (!mounted) return;
    if (outcome.completedDay != null || outcome.levelUp != null) {
      await showCelebration(
        context,
        state: state,
        day: outcome.completedDay,
        levelUp: outcome.levelUp,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final task = widget.task;
    final done = state.isDone(task);
    final scheme = Theme.of(context).colorScheme;
    final catColor = categoryColor(task.category, scheme);
    final hasDetails = task.details.isNotEmpty;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: done ? 0.62 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: hasDetails ? () => setState(() => _expanded = !_expanded) : () => _toggle(state),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _toggle(state),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 10, 0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                    child: Icon(
                      done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      key: ValueKey(done),
                      size: 28,
                      color: done ? scheme.primary : scheme.outline,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 3),
                    RichLine(
                      task.text,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.35,
                        color: scheme.onSurface,
                        decoration: done ? TextDecoration.lineThrough : null,
                        decorationColor: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (task.tag != null) SmallChip(task.tag!, color: catColor),
                        if (task.isOptional) const SmallChip('optional'),
                        for (final chip in task.chips)
                          SmallChip(
                            chip,
                            icon: chip == 'setup' ? Icons.build_rounded : Icons.folder_rounded,
                            color: catColor,
                          ),
                        if (hasDetails)
                          SmallChip(
                            _expanded ? 'hide details' : 'input / output',
                            icon: _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                            color: scheme.primary,
                          ),
                      ],
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.topCenter,
                      child: _expanded
                          ? Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final d in task.details)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 3),
                                      child: RichLine(
                                        d,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          height: 1.35,
                                          color: scheme.onSurface,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
