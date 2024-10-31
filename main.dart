import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Кінотеатр',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.deepPurple[100], // Фон фиолетового цвета
      ),
      home: MovieSelectionScreen(),
    );
  }
}

// Глобальный список для хранения забронированных сеансов
List<String> bookedSessions = [];

class MovieSelectionScreen extends StatelessWidget {
  final List<String> movies = ['Мауглі', 'Кінг Конг', 'Марсіянин', 'Супермен'];

  void _viewBookedSessions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookedSessionsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Вибір фільму'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: movies.map((movie) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SessionSelectionScreen(movie: movie)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // Скругленные углы
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      ),
                      child: Text(movie, style: TextStyle(fontSize: 24)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0), // Отступ от нижнего края
            child: ElevatedButton(
              onPressed: () => _viewBookedSessions(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: Text('Переглянути заброньовані сеанси', style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }
}

class SessionSelectionScreen extends StatelessWidget {
  final String movie;
  final List<String> sessions = ['10:00', '13:00', '16:00', '19:00'];

  SessionSelectionScreen({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Сеанси для $movie'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end, // Выравнивание по правому краю
          children: sessions.map((session) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SeatingChartScreen(session: session, movie: movie)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Скругленные углы
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text(session, style: TextStyle(fontSize: 20)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class SeatingChartScreen extends StatefulWidget {
  final String session;
  final String movie;

  SeatingChartScreen({required this.session, required this.movie});

  @override
  _SeatingChartScreenState createState() => _SeatingChartScreenState();
}

class _SeatingChartScreenState extends State<SeatingChartScreen> {
  final int rows = 8;
  final int seatsPerRow = 10;
  late List<List<bool>> _seats;

  @override
  void initState() {
    super.initState();
    _seats = List.generate(rows, (_) => List.generate(seatsPerRow, (_) => false));
  }

  void _toggleSeat(int row, int seat) {
    setState(() {
      _seats[row][seat] = !_seats[row][seat];
    });
  }

  void _bookSeats() {
    List<String> bookedSeats = [];
    for (int row = 0; row < rows; row++) {
      for (int seat = 0; seat < seatsPerRow; seat++) {
        if (_seats[row][seat]) {
          bookedSeats.add('${row + 1}-${seat + 1}'); // Сохраняем занятые места
        }
      }
    }

    if (bookedSeats.isNotEmpty) {
      String bookedSession = 'Фільм: ${widget.movie}, Час: ${widget.session}, Місця: ${bookedSeats.join(', ')}';
      // Добавляем забронированный сеанс в глобальный список
      bookedSessions.add(bookedSession);

      // Показать сообщение об успешном бронировании
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Місця заброньовано!')),
      );
    } else {
      // Показать сообщение об ошибке
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Будь ласка, виберіть місця для бронювання!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Вибір місць - ${widget.session}'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int row = 0; row < rows; row++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int seat = 0; seat < seatsPerRow; seat++)
                    GestureDetector(
                      onTap: () => _toggleSeat(row, seat),
                      child: Container(
                        margin: EdgeInsets.all(4.0),
                        width: 40, // Увеличенный размер мест
                        height: 40,
                        color: _seats[row][seat] ? Colors.green : Colors.grey,
                        child: Center(
                          child: Text(
                            '${row + 1}-${seat + 1}',
                            style: TextStyle(color: Colors.white, fontSize: 12), // Крупный текст
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _bookSeats,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: Text('Забронювати', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

class BookedSessionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Заброньовані сеанси'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: bookedSessions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(bookedSessions[index]),
          );
        },
      ),
    );
  }
}
