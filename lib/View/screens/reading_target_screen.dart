import 'package:all_booked/database/shared.dart';
import 'package:flutter/material.dart';

import 'package:all_booked/View/screens/home_screen.dart';
import 'package:go_router/go_router.dart';

class ReadingTargetScreen extends StatefulWidget {
  const ReadingTargetScreen({Key? key}) : super(key: key);

  static const String routeName = '/readingtarget';

  @override
  _ReadingTargetScreenState createState() => _ReadingTargetScreenState();
}

class _ReadingTargetScreenState extends State<ReadingTargetScreen> {
  int selectedFrequency = 1;
  int dailyChaptersNeeded = 4;

  @override
  void initState() {
    _loadSharedPreferences();
    super.initState();
  }

  void _updateSelectedFrequency(int frequency) {
    setState(() {
      selectedFrequency = frequency;
      // Calculăm numărul de capitole zilnice necesare
      dailyChaptersNeeded = (frequency * 1189 / 365).ceil();
    });
  }

  void _loadSharedPreferences() async {
    final int? targetReading =
        await SharedPreferencesManager.getReadingTarget();
    final int? chaptersNeeded =
        await SharedPreferencesManager.getDailyChaptersNeeded();
    setState(() {
      selectedFrequency = targetReading ?? 1;
      dailyChaptersNeeded = chaptersNeeded ?? 4;
    });
  }

  void _saveAndNavigate(BuildContext context) async {
    await SharedPreferencesManager.setReadingTarget(selectedFrequency);
    await SharedPreferencesManager.setDailyChaptersNeeded(dailyChaptersNeeded);

    // ignore: use_build_context_synchronously
    context.go(HomeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setare citire Biblie'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const Image(
                  image: AssetImage('assets/images/citirezilnica.png'),
                ),
              ),
            ),
            const Spacer(
              flex: 2,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                'Selectați de câte ori doriți să citiți Biblia pe an:',
                style: TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20.0),
            Slider(
              value: selectedFrequency.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: selectedFrequency.round().toString(),
              onChanged: (value) {
                _updateSelectedFrequency(value.toInt());
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  10,
                  (index) {
                    final frequency = index + 1;
                    return Text(
                      frequency.toString(),
                      style: const TextStyle(fontSize: 14),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 50.0),
            Text(
              'Trebuie să citiți zilnic $dailyChaptersNeeded capitole.',
              style: const TextStyle(fontSize: 16.0),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _saveAndNavigate(context),
        child: const Icon(Icons.arrow_forward),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
