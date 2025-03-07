import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:what_bytes_task/screens/common.dart';
import 'package:what_bytes_task/screens/login_screen.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../providers/auth_provider.dart';

class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({super.key});

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen> {
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    intial();
  }

  void intial() {
    ref
        .read(taskListProvider.notifier)
        .setUserId(ref.read(authRepositoryProvider).getUser()!.uid);
    ref.read(taskListProvider.notifier).fetchTasks();
    setState(() {
      isLoading = false;
    });
  }

  void logout() async {
    try {
      await ref.read(authRepositoryProvider).signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged Out successfully!')),
      );
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) {
        return const LoginScreen();
      }), (s) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Widget _priorityButton(String label, Color color, String selected,
      ValueNotifier<String> selectedPriority) {
    return GestureDetector(
      onTap: () => selectedPriority.value = label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected == label ? color.withOpacity(0.3) : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
          border: selected == label
              ? Border.all(
                  color: color,
                  width: 2) // Only show border for selected priority
              : Border.all(color: Colors.transparent, width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    final taskList = ref.watch(taskListProvider);

    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final thisWeek = today.add(const Duration(days: 7));

    final todayTasks =
        taskList.where((task) => _isSameDay(task.dueDate, today)).toList();
    final tomorrowTasks =
        taskList.where((task) => _isSameDay(task.dueDate, tomorrow)).toList();
    final thisWeekTasks = taskList
        .where((task) =>
            task.dueDate.isAfter(today) &&
            task.dueDate.isBefore(thisWeek) &&
            !_isSameDay(task.dueDate, tomorrow))
        .toList();

    final laterTasks =
        taskList.where((task) => task.dueDate.isAfter(thisWeek)).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.withOpacity(.5),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Task Manager",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat("d, MMM")
                  .format(DateTime.now()), // Formats as "1, May"
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: logout,
          ),
        ],
      ),
      body: (isLoading)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: LiquidPullToRefresh(
                animSpeedFactor: 2,
                color: Colors.deepPurple.shade300,
                height: 50,
                showChildOpacityTransition: false,
                onRefresh: () async {
                  ref.read(taskListProvider.notifier).fetchTasks();
                },
                child: ListView(
                  children: [
                    if (todayTasks.isNotEmpty)
                      TaskSection(title: "Today", tasks: todayTasks, ref: ref),
                    if (tomorrowTasks.isNotEmpty)
                      TaskSection(
                          title: "Tomorrow", tasks: tomorrowTasks, ref: ref),
                    if (thisWeekTasks.isNotEmpty)
                      TaskSection(
                          title: "This Week", tasks: thisWeekTasks, ref: ref),
                    if (laterTasks.isNotEmpty)
                      TaskSection(title: "Later", tasks: laterTasks, ref: ref),
                    if (taskList.isEmpty)
                      const Center(
                          child: Text("No tasks Found",
                              style: TextStyle(fontSize: 16))),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(context, ref),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showTaskDialog(BuildContext context, WidgetRef ref, [Task? task]) {
    final titleController = TextEditingController(text: task?.title ?? "");
    final descriptionController =
        TextEditingController(text: task?.description ?? "");
    ValueNotifier<String> selectedPriority =
        ValueNotifier("Medium"); // Default priority
    DateTime dueDate = task?.dueDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(task == null ? "Add Task" : "Edit Task"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Field(
                    titleController: titleController,
                    hinttext: "Title",
                    maxLines: 1,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Field(
                      titleController: descriptionController,
                      maxLines: 2,
                      hinttext: "Description"),
                  const SizedBox(height: 10),
                  const Text(
                    "Priority:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ValueListenableBuilder<String>(
                    valueListenable: selectedPriority,
                    builder: (context, value, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _priorityButton(
                              "High", Colors.red, value, selectedPriority),
                          _priorityButton(
                              "Medium", Colors.orange, value, selectedPriority),
                          _priorityButton(
                              "Low", Colors.green, value, selectedPriority),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: dueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          dueDate = pickedDate;
                        });
                      }
                    },
                    child: Text(
                      "Pick Due Date  -  ${DateFormat("d, MMM").format(dueDate)}",
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    final newTask = Task(
                      id: task?.id ?? "",
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      dueDate: dueDate,
                      priority: selectedPriority
                          .value, // Ensuring selected priority is stored
                      isCompleted: task?.isCompleted ?? false,
                    );

                    if (task == null) {
                      ref.read(taskListProvider.notifier).addTask(newTask);
                    } else {
                      ref.read(taskListProvider.notifier).updateTask(newTask);
                    }

                    Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class Field extends StatelessWidget {
  const Field({
    super.key,
    required this.titleController,
    required this.hinttext,
    required this.maxLines,
  });

  final TextEditingController titleController;
  final String hinttext;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: titleController,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.white),
        ),
        hintText: hinttext,
        hintStyle: kTextStyle.copyWith(color: Colors.black54),
      ),
    );
  }
}

class TaskSection extends StatefulWidget {
  final String title;
  final List<Task> tasks;
  final WidgetRef ref;

  const TaskSection(
      {super.key, required this.title, required this.tasks, required this.ref});

  @override
  _TaskSectionState createState() => _TaskSectionState();
}

class _TaskSectionState extends State<TaskSection> {
  late List<Task> originalTasks;
  late List<Task> displayedTasks;
  bool isPrioritySorted = false;
  bool isStatusSorted = false;

  @override
  void initState() {
    super.initState();
    originalTasks = List.from(widget.tasks);
    displayedTasks = List.from(widget.tasks);
  }

  void toggleSorting() {
    setState(() {
      displayedTasks = List.from(originalTasks);

      if (isStatusSorted) {
        displayedTasks
            .sort((a, b) => a.isCompleted ? 1 : -1); // Incomplete first
      }
      if (isPrioritySorted) {
        displayedTasks = sortTasksByPriority(displayedTasks);
      }
    });
  }

  List<Task> sortTasksByPriority(List<Task> tasks) {
    const priorityOrder = {"High": 1, "Medium": 2, "Low": 3};

    tasks.sort((a, b) {
      return (priorityOrder[a.priority] ?? 3)
          .compareTo(priorityOrder[b.priority] ?? 3);
    });
    setState(() {});

    return tasks;
  }

  void deleteTask(WidgetRef ref, Task task) async {
    await ref.read(taskListProvider.notifier).deleteTask(task.id);
  }

  Widget _priorityTag(String priority) {
    Color color;
    switch (priority) {
      case "High":
        color = Colors.red;
        break;
      case "Medium":
        color = Colors.orange;
        break;
      case "Low":
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTaskCard(Task task, WidgetRef ref) {
    return Dismissible(
      key: Key(task.id), // Unique key for swipe action
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        deleteTask(ref, task);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _priorityTag(task.priority),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                task.description,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat("d MMM").format(task.dueDate),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) {
                      ref
                          .read(taskListProvider.notifier)
                          .toggleTaskCompletion(task.id, value ?? false);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade300),
        color: Colors.purple.shade50,
      ),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Text(
                      "Status",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Checkbox(
                      value: isStatusSorted,
                      onChanged: (value) {
                        setState(() {
                          isStatusSorted = !isStatusSorted;
                          toggleSorting();
                        });
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      "Priority",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Checkbox(
                      value: isPrioritySorted,
                      onChanged: (value) {
                        setState(() {
                          isPrioritySorted = !isPrioritySorted;
                          toggleSorting();
                        });
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: displayedTasks
                .map((task) => _buildTaskCard(task, widget.ref))
                .toList(),
          ),
        ],
      ),
    );
  }
}
