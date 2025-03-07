// // import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/task.dart';
// import '../providers/task_provider.dart';
// import 'package:intl/intl.dart';

// class TaskScreen extends ConsumerWidget {
//   const TaskScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final taskList = ref.watch(taskListProvider);

//     // Get today's and future dates
//     final today = DateTime.now();
//     final tomorrow = today.add(const Duration(days: 1));
//     final thisWeek = today.add(const Duration(days: 7));

//     final todayTasks = taskList.where((task) => _isSameDay(task.dueDate, today)).toList();
//     final tomorrowTasks = taskList.where((task) => _isSameDay(task.dueDate, tomorrow)).toList();
//     final thisWeekTasks = taskList.where((task) =>
//         task.dueDate.isAfter(today) &&
//         task.dueDate.isBefore(thisWeek) &&
//         !_isSameDay(task.dueDate, tomorrow)).toList();
//     final laterTasks = taskList.where((task) => task.dueDate.isAfter(thisWeek)).toList();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Task Manager", style: TextStyle(fontWeight: FontWeight.bold)),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(12),
//         child: ListView(
//           children: [
//             if (todayTasks.isNotEmpty) _buildSection("Today", todayTasks, ref),
//             if (tomorrowTasks.isNotEmpty) _buildSection("Tomorrow", tomorrowTasks, ref),
//             if (thisWeekTasks.isNotEmpty) _buildSection("This Week", thisWeekTasks, ref),
//             if (laterTasks.isNotEmpty) _buildSection("Later", laterTasks, ref),
//             if (taskList.isEmpty)
//               const Center(child: Text("No tasks available", style: TextStyle(fontSize: 16))),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showTaskDialog(context, ref),
//         backgroundColor: Colors.blue,
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }

//   /// Creates a task section with a header
//   Widget _buildSection(String title, List<Task> tasks, WidgetRef ref) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Text(
//             title,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//         ),
//         ...tasks.map((task) => _buildTaskCard(task, ref)).toList(),
//       ],
//     );
//   }

//   /// Creates a swipe-to-delete task card
//   Widget _buildTaskCard(Task task, WidgetRef ref) {
//     return Dismissible(
//       key: Key(task.id!), // Unique key for swipe action
//       direction: DismissDirection.endToStart,
//       background: Container(
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.only(right: 16),
//         color: Colors.red,
//         child: const Icon(Icons.delete, color: Colors.white),
//       ),
//       onDismissed: (_) {
//         ref.read(taskListProvider.notifier).deleteTask(task.id!);
//       },
//       child: Card(
//         margin: const EdgeInsets.symmetric(vertical: 6),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         elevation: 3,
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       task.title,
//                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   _priorityTag(task.priority),
//                 ],
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 task.description,
//                 style: const TextStyle(fontSize: 14, color: Colors.grey),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     DateFormat("d MMM").format(task.dueDate),
//                     style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//                   ),
//                   Checkbox(
//                     value: task.isCompleted,
//                     onChanged: (value) {
//                       ref
//                           .read(taskListProvider.notifier)
//                           .toggleTaskCompletion(task.id!, value ?? false);
//                     },
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// Returns a styled priority tag
//   Widget _priorityTag(String priority) {
//     Color color;
//     switch (priority) {
//       case "High":
//         color = Colors.red;
//         break;
//       case "Medium":
//         color = Colors.orange;
//         break;
//       case "Low":
//         color = Colors.green;
//         break;
//       default:
//         color = Colors.grey;
//     }
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text(
//         priority,
//         style: TextStyle(color: color, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   /// Checks if two dates are the same day
//   bool _isSameDay(DateTime date1, DateTime date2) {
//     return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
//   }
// }
