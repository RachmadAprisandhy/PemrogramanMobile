import 'package:flutter/material.dart';
import 'Mahasiswa.dart';
import 'LirikLagu.dart';
void main() {
  runApp(const Rachmad());
}

class Rachmad extends StatelessWidget {
  const Rachmad({super.key});


  @override
  Widget build(BuildContext context) {
    final mahasiswa = Mahasiswa(nama: 'Rachmad Aprisandhy', umur: '20', kelas: 'Pemrograman Mobile - Minggu 1');
    final lirikLagu = LirikLagu(judul: 'Happines', penyanyi: 'Rex Orange County', lirik: 'I ll be the one that stays til the end And Ill be the one that needs you again And Ill be the one that proposes in a garden of roses And truly loves you long after our curtain closes.');
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Lyric'),
        ),
        body:  Center(
         child: Container(
          width: 400,
          height: 500,
          child: Center(
            child: Text(
              'Judul: ${lirikLagu.judul} Penyanyi: ${lirikLagu.penyanyi} Lirik: ${lirikLagu.lirik}',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
            ),
          ),
        )
      ),  
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50,
          child: Center(
            child: Row(
              children: [
                Text('Judul: ${lirikLagu.judul}'),
                Spacer(),
                Icon(Icons.arrow_back),
                Icon(Icons.play_arrow),
                Icon(Icons.pause),
                Icon(Icons.arrow_forward),
                Spacer(),
                Text('Penyanyi: ${lirikLagu.penyanyi}'),
              ],
            ),
          ),
        ),  
      ),
    ),
    );
  }
}

