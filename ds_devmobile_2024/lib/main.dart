import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  //Crée l'application Todo avec gestionnaire de tâches et navigation vers les écrans de filtrage et d'ajout.

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: MaterialApp(
        title: 'Todo App',
        home: const TaskScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          FilteredTasksScreen.routeName: (context) =>
              const FilteredTasksScreen(),
          AddTaskScreen.routeName: (context) => const AddTaskScreen(),
        },
      ),
    );
  }
}

class TaskProvider with ChangeNotifier {
  //Cette classe gère une liste de tâches et permet d'accéder aux tâches, d'en ajouter de nouvelles et d'être notifié des modifications.
  final List<Task> _tasks = [
    Task(name: 'Task 1', color: Colors.grey, status: 'Todo'),
    Task(name: 'Task 2', color: Colors.green, status: 'In progress'),
    Task(name: 'Task 3', color: Colors.red, status: 'Bug'),
    Task(name: 'Task 4', color: Colors.red, status: 'Bug'),
    Task(name: 'Task 5', color: Colors.grey, status: 'Todo'),
    Task(name: 'Task 6', color: Colors.grey, status: 'Todo'),
    Task(name: 'Task 7', color: Colors.lightBlue, status: 'Done'),
  ];

  List<Task> _filteredTasks = [];

  List<Task> get tasks => _tasks;
  List<Task> get filteredTasks => _filteredTasks;

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void updateTask(int index, Task task) {
    _tasks[index] = task;
    notifyListeners();
  }

  void applyFilters(List<String> filters) {
    _filteredTasks =
        _tasks.where((task) => filters.contains(task.status)).toList();
    notifyListeners();
  }
}

class Task {
  //Représente une tâche individuelle
  String name;
  Color color;
  String status;
  String description; // Ajout de la description de la tâche

  Task(
      {required this.name,
      required this.color,
      required this.status,
      this.description = ''});
}

class TaskScreen extends StatelessWidget {
  //Écran principal affichant la liste des tâches
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //: Construit l'écran principal en utilisant les widgets suivants :
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => FilterDialog(),
              );
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return TaskList(
              taskProvider:
                  taskProvider); // Passer le fournisseur de tâches à TaskList
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AddTaskScreen.routeName).then((value) {
            // Recharger la liste des tâches lorsque vous revenez de AddTaskScreen
            Provider.of<TaskProvider>(context, listen: false).notifyListeners();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  //Cette classe hérite de StatelessWidget, indiquant que son apparence ne changera pas dynamiquement au cours du cycle de vie de l'application.
  final TaskProvider taskProvider;

  const TaskList({super.key, required this.taskProvider});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: taskProvider.tasks.length,
      itemBuilder: (context, index) {
        return TaskTile(
          task: taskProvider.tasks[index],
          index: index,
        );
      },
    );
  }
}

class TaskTile extends StatelessWidget {
  //Cette classe hérite de StatelessWidget et définit l'apparence d'une seule tâche dans la liste des tâches de l'application Todo.
  final Task task;
  final int index;

  const TaskTile(
      {super.key,
      required this.task,
      required this.index}); //Le constructeur prend deux arguments obligatoires : task: La tâche à afficher.  index: L'index de la tâche dans la liste.

  @override
  Widget build(BuildContext context) {
    // Construit l'élément de la liste en utilisant un widget ListTile.
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: task.color,
      ),
      title: Text(task.name),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => TaskDialog(
            task: task,
            index: index,
          ),
        );
      },
    );
  }
}

class TaskDialog extends StatefulWidget {
  //La classe TaskDialog dans le code que vous avez fourni gère la boîte de dialogue de modification des tâches. Voici une explication détaillée de son fonctionnement
  final Task? task;
  final int? index;

  const TaskDialog({super.key, this.task, this.index});

  @override
  _TaskDialogState createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  //classe d'état interne associée à la classe TaskDialog vue précédemment. Elle gère l'état et le comportement de la boîte de dialogue de modification des tâches.
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late Color _color;
  late String _status;
  late String _description; // Ajout de la description de la tâche

  @override
  void initState() {
    super.initState();
    // Initialise l'état de la boîte de dialogue de tâche
    _name = widget.task?.name ??
        ''; // Récupère le nom de la tâche du widget parent, ou une chaîne vide si aucune tâche n'est fournie
    _color = widget.task?.color ??
        Colors
            .grey; // Récupère la couleur de la tâche du widget parent, ou gris par défaut
    _status = widget.task?.status ??
        'Todo'; // Récupère le statut de la tâche du widget parent, ou "Todo" par défaut
    _description = widget.task?.description ??
        ''; // Récupère la description de la tâche du widget parent, ou une chaîne vide si aucune description n'est fournie (NOUVEAU)
  }

  @override
  // Construit le contenu de la boîte de dialogue de tâche
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _name,
              decoration: const InputDecoration(labelText: 'Task Name'),
              onSaved: (value) {
                _name = value ?? '';
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<Color>(
              value: _color,
              items: const [
                DropdownMenuItem(
                  value: Colors.grey,
                  child: Text('Grey'),
                ),
                DropdownMenuItem(
                  value: Colors.green,
                  child: Text('Green'),
                ),
                DropdownMenuItem(
                  value: Colors.red,
                  child: Text('Red'),
                ),
                DropdownMenuItem(
                  value: Colors.lightBlue,
                  child: Text('Light Blue'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _color = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Task Color'),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _status,
              items: const [
                DropdownMenuItem(
                  value: 'Todo',
                  child: Text('Todo'),
                ),
                DropdownMenuItem(
                  value: 'In progress',
                  child: Text('In progress'),
                ),
                DropdownMenuItem(
                  value: 'Done',
                  child: Text('Done'),
                ),
                DropdownMenuItem(
                  value: 'Bug',
                  child: Text('Bug'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Task Status'),
            ),
            const SizedBox(height: 20),
            // Champ de saisie pour la description de la tâche (ajouté)
            TextFormField(
              // Ajout du champ de saisie de la description
              initialValue: _description,
              decoration: const InputDecoration(labelText: 'Description'),
              onSaved: (value) {
                _description = value ?? '';
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        // Bouton d'enregistrement
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final task = Task(
                  name: _name,
                  color: _color,
                  status: _status,
                  description: _description);
              if (widget.task == null) {
                Provider.of<TaskProvider>(context, listen: false).addTask(task);
              } else {
                Provider.of<TaskProvider>(context, listen: false)
                    .updateTask(widget.index!, task);
              }
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.task == null ? 'Add' : 'Update'),
        ),
        // Bouton de fermeture (ajouté)
        TextButton(
          onPressed: () {
            Navigator.of(context)
                .pop(); // Ajout du bouton "X" pour fermer la boîte de dialogue
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class FilterDialog extends StatefulWidget {
  // a classe FilterDialog est un modèle pour la boîte de dialogue de filtrage des tâches.

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  final List<String> _filters = ['Todo', 'In progress', 'Done', 'Bug'];
  final Map<String, bool> _filterSelection = {
    'Todo': false,
    'In progress': false,
    'Done': false,
    'Bug': false,
  };

  @override
  Widget build(BuildContext context) {
    // Construit le contenu de la boîte de dialogue de filtrage
    return AlertDialog(
      title: const Text('Filter by'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _filters.map((filter) {
          return CheckboxListTile(
            title: Text(filter),
            value: _filterSelection[filter],
            onChanged: (value) {
              setState(() {
                _filterSelection[filter] = value!;
              });
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            List<String> selectedFilters =
                _filters.where((filter) => _filterSelection[filter]!).toList();
            Provider.of<TaskProvider>(context, listen: false)
                .applyFilters(selectedFilters);
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(FilteredTasksScreen.routeName);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class FilteredTasksScreen extends StatelessWidget {
  static const routeName = '/filtered-tasks';

  const FilteredTasksScreen({super.key});

  @override
  //Cet écran affiche une liste de tâches filtrées en utilisant le widget ListView.builder. Il récupère les tâches filtrées à partir du TaskProvider et les affiche individuellement à l'aide de widgets TaskTile
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final filteredTasks = taskProvider.filteredTasks;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtered Tasks'),
      ),
      body: ListView.builder(
        itemCount: filteredTasks.length, // Nombre d'éléments de la liste
        itemBuilder: (context, index) {
          return TaskTile(
            task: filteredTasks[index],
            index: taskProvider.tasks.indexOf(filteredTasks[index]),
          );
        },
      ),
    );
  }
}

class AddTaskScreen extends StatefulWidget {
  // permet la modification de l'écran au cours de son utilisation.
  static const routeName = '/add-task';

  const AddTaskScreen({super.key});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  //Gère l'état de l'écran d'ajout de tâche.
  final _formKey = GlobalKey<FormState>();
  String _taskName = '';
  String _taskDescription = '';
  String _taskStatus = 'Todo';
  final Color _taskColor = Colors.grey;

  @override
  //e code définit la construction de l'écran d'ajout de tâche
  Widget build(BuildContext context) {
    //La méthode build construit l'interface de l'écran.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une tâche'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _taskStatus,
                items: const [
                  DropdownMenuItem(
                    value: 'Todo',
                    child: Text('Todo'),
                  ),
                  DropdownMenuItem(
                    value: 'In progress',
                    child: Text('In progress'),
                  ),
                  DropdownMenuItem(
                    value: 'Done',
                    child: Text('Done'),
                  ),
                  DropdownMenuItem(
                    value: 'Bug',
                    child: Text('Bug'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _taskStatus = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nom de la tâche'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer un nom de tâche';
                  }
                  return null;
                },
                onSaved: (value) {
                  _taskName = value!;
                },
              ),
              TextFormField(
                maxLines: 3,
                decoration:
                    const InputDecoration(labelText: 'Description de la tâche'),
                onSaved: (value) {
                  _taskDescription = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final taskProvider =
                        Provider.of<TaskProvider>(context, listen: false);
                    taskProvider.addTask(Task(
                      name: _taskName,
                      color: _taskColor,
                      status: _taskStatus,
                      description: _taskDescription,
                    ));
                    Navigator.pop(context);
                  }
                },
                child: const Text('Ajouter'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.close, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
