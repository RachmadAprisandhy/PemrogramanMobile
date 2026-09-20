import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'Mahasiswa.dart';
import 'LirikLagu.dart';

void main() {
  runApp(const Rachmad());
}

class Rachmad extends StatefulWidget {
  const Rachmad({super.key});

  @override
  State<Rachmad> createState() => _RachmadState();
}

class _RachmadState extends State<Rachmad> {
  final AudioPlayer player = AudioPlayer();

  // TAMBAHAN: fungsi untuk memutar lagu
  Future<void> playMusic() async {
    try {
      await player.play(
        AssetSource('audio/Happiness.mp3'),
      );

      print('Lagu berhasil diputar');
    } catch (e) {
      print('ERROR AUDIO: $e');
    }
  }

  // TAMBAHAN: fungsi untuk pause lagu
  Future<void> pauseMusic() async {
    try {
      await player.pause();

      print('Lagu di-pause');
    } catch (e) {
      print('ERROR PAUSE: $e');
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mahasiswa = Mahasiswa(
      nama: 'Rachmad Aprisandhy',
      umur: '20',
      kelas: 'Pemrograman Mobile - Minggu 1',
    );

    final lirikLagu = LirikLagu(
      judul: 'Happines',
      penyanyi: 'Rex Orange County',
      lirik:
          'I ll be the one that stays til the end '
          'And Ill be the one that needs you again '
          'And Ill be the one that proposes in a garden of roses '
          'And truly loves you long after our curtain closes.',
    );

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Lyric'),
        ),

        body: Row(
          children: [

            // Playlist di sebelah kiri
            SizedBox(
              width: 280,
              child: Card(
                child: Column(
                  children: [
                    const SizedBox(height: 15),

                    const Text(
                      'Your Playlist',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ListView untuk menampilkan daftar lagu
                    Expanded(
                      child: ListView(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.music_note),
                              const SizedBox(width: 10),
                              const Text('Happiness'),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              const Icon(Icons.music_note),
                              const SizedBox(width: 10),
                              const Text('Loving Is Easy'),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              const Icon(Icons.music_note),
                              const SizedBox(width: 10),
                              const Text('Sunflower'),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              const Icon(Icons.music_note),
                              const SizedBox(width: 10),
                              const Text('Best Friend'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Cover dan lirik di tengah
            Expanded(
              child: Center(
                child: Container(
                  width: 400,
                  height: 500,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      // Cover lagu
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          'assets/happines.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Lirik
                      Text(
                        'Judul: ${lirikLagu.judul}\n'
                        'Penyanyi: ${lirikLagu.penyanyi}\n\n'
                        '${lirikLagu.lirik}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        bottomNavigationBar: BottomAppBar(
          child: Container(
            height: 50,
            child: Center(
              child: Row(
                children: [

                  Text('Judul: ${lirikLagu.judul}'),

                  Spacer(),

                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      // Aksi ketika tombol back ditekan
                    },
                  ),

                  Spacer(),

                  // TOMBOL PLAY
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () {
                      playMusic();
                    },
                  ),

                  Spacer(),

                  // TOMBOL PAUSE
                  IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: () {
                      pauseMusic();
                    },
                  ),

                  Spacer(),

                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () {
                      // Aksi ketika tombol forward ditekan
                    },
                  ),

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