import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'Mahasiswa.dart';
import 'LirikLagu.dart';

void main() {
  runApp(const Rachmad());
}

// =====================================================
// INHERITEDWIDGET
// =====================================================
class MusicPlayerInherited extends InheritedWidget {
  final String currentSong;
  final bool playerActive;
  final double volume;

  const MusicPlayerInherited({
    super.key,
    required this.currentSong,
    required this.playerActive,
    required this.volume,
    required super.child,
  });

  static MusicPlayerInherited of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MusicPlayerInherited>()!;
  }

  @override
  bool updateShouldNotify(MusicPlayerInherited oldWidget) {
    return currentSong != oldWidget.currentSong ||
        playerActive != oldWidget.playerActive ||
        volume != oldWidget.volume;
  }
}

// =====================================================
// STATEFULWIDGET
// =====================================================
class Rachmad extends StatefulWidget {
  const Rachmad({super.key});

  @override
  State<Rachmad> createState() => _RachmadState();
}

class _RachmadState extends State<Rachmad>
    with SingleTickerProviderStateMixin {
  final AudioPlayer player = AudioPlayer();

  // =====================================================
  // VALUELISTENABLEBUILDER
  // =====================================================
  final ValueNotifier<String> currentSongNotifier =
      ValueNotifier<String>('Happiness');

  // =====================================================
  // FORM
  // =====================================================
  final _formKey = GlobalKey<FormState>();

  // =====================================================
  // CHECKBOX
  // =====================================================
  bool happinessSelected = false;
  bool lovingIsEasySelected = false;

  // =====================================================
  // RADIO
  // =====================================================
  String repeatMode = 'Repeat All';

  // =====================================================
  // SWITCH
  // =====================================================
  bool shuffle = false;

  // =====================================================
  // SLIDER
  // =====================================================
  double volume = 0.5;

  // =====================================================
  // REORDERABLELISTVIEW
  // =====================================================
  List<String> playlist = [
    'Happiness',
    'Loving Is Easy',
    'Sunflower',
    'Best Friend',
  ];

  // =====================================================
  // BOTTOMNAVIGATIONBAR
  // =====================================================
  int selectedBottomIndex = 0;

  // =====================================================
  // NAVIGATIONRAIL
  // =====================================================
  int selectedRailIndex = 0;

  // =====================================================
  // CIRCULARPROGRESSINDICATOR
  // =====================================================
  bool isLoading = false;

  // =====================================================
  // ANIMATEDCONTAINER
  // =====================================================
  bool playerActive = false;

  // =====================================================
  // ANIMATEDOPACITY
  // =====================================================
  bool showPlayerInfo = true;

  // =====================================================
  // SCALETRANSITION
  // =====================================================
  late AnimationController scaleController;
  late Animation<double> scaleAnimation;

  // =====================================================
  // MENCEGAH PLAY BERULANG
  // =====================================================
  bool isAudioBusy = false;

  // =====================================================
  // FUTUREBUILDER
  // =====================================================
  late Future<Mahasiswa> mahasiswaFuture;

  // =====================================================
  // STREAMBUILDER
  // =====================================================
  late Stream<String> statusStream;

  // =====================================================
  // STREAMBUILDER
  // =====================================================
  Stream<String> playerStatusStream() async* {
    while (true) {
      await Future.delayed(
        const Duration(seconds: 1),
      );

      if (playerActive) {
        yield 'Lagu sedang diputar';
      } else {
        yield 'Lagu sedang di-pause';
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // =====================================================
    // ANIMATION CONTROLLER
    // =====================================================
    scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(
      CurvedAnimation(
        parent: scaleController,
        curve: Curves.easeInOut,
      ),
    );

    // =====================================================
    // FUTUREBUILDER
    // =====================================================
    mahasiswaFuture = getMahasiswa();

    // =====================================================
    // STREAMBUILDER
    // =====================================================
    statusStream = playerStatusStream();
  }

  // =====================================================
  // FUTUREBUILDER
  // =====================================================
  Future<Mahasiswa> getMahasiswa() async {
    await Future.delayed(
      const Duration(seconds: 1),
    );

    return Mahasiswa(
      nama: 'Rachmad Aprisandhy',
      umur: '21',
      kelas: 'Pemrograman Mobile - Minggu 3',
    );
  }

  // =====================================================
  // FUNGSI PLAY MUSIC
  // =====================================================
  Future<void> playMusic() async {
    // Mencegah tombol play dipanggil berkali-kali
    if (isAudioBusy) {
      return;
    }

    isAudioBusy = true;

    if (mounted) {
      setState(() {
        isLoading = true;
        showPlayerInfo = true;
      });
    }

    currentSongNotifier.value = 'Happiness';

    try {
      await player.play(
        AssetSource('audio/Happiness.mp3'),
        volume: volume,
      );

      // HANYA AKTIF JIKA AUDIO BERHASIL DIPUTAR
      if (mounted) {
        setState(() {
          playerActive = true;
          isLoading = false;
        });
      }

      print('Lagu berhasil diputar');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Lagu Happiness sedang diputar',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('ERROR AUDIO: $e');

      if (mounted) {
        setState(() {
          playerActive = false;
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memutar lagu: $e',
            ),
          ),
        );
      }
    } finally {
      isAudioBusy = false;
    }
  }

  // =====================================================
  // FUNGSI PAUSE MUSIC
  // =====================================================
  Future<void> pauseMusic() async {
    if (isAudioBusy) {
      return;
    }

    try {
      await player.pause();

      if (mounted) {
        setState(() {
          playerActive = false;
          showPlayerInfo = false;
        });
      }

      print('Lagu di-pause');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Lagu di-pause',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('ERROR PAUSE: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal melakukan pause',
            ),
          ),
        );
      }
    }
  }

  // =====================================================
  // SHOW MODAL BOTTOM SHEET
  // =====================================================
  void showMusicInfo() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'Informasi Lagu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Judul: Happines',
              ),

              const Text(
                'Penyanyi: Rex Orange County',
              ),

              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Tutup',
                    ),
                  ),

                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      playMusic();
                    },
                    child: const Text(
                      'Putar',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // =====================================================
  // SHOW DIALOG + ALERTDIALOG
  // =====================================================
  void showPlaylistDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Simpan Playlist',
          ),

          content: const Text(
            'Apakah kamu yakin ingin menyimpan playlist ini?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Batal',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(
                  this.context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Playlist berhasil disimpan',
                    ),
                  ),
                );
              },
              child: const Text(
                'Simpan',
              ),
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // PAGE ROUTE BUILDER
  // =====================================================
  void openSongPage(String lagu) {
    if (mounted) {
      setState(() {
        showPlayerInfo = true;
      });
    }

    currentSongNotifier.value = lagu;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Memilih lagu: $lagu',
        ),
        duration: const Duration(seconds: 1),
      ),
    );

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return Scaffold(
            appBar: AppBar(
              title: Text(lagu),
            ),

            body: Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  // =====================================================
                  // HERO
                  // =====================================================
                  if (lagu == 'Happiness')
                    Hero(
                      tag: 'cover-happiness',
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(15),
                        child: Image.asset(
                          'assets/happines.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    const Icon(
                      Icons.music_note,
                      size: 100,
                    ),

                  const SizedBox(height: 20),

                  Text(
                    lagu,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Rex Orange County',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton.icon(
                    onPressed: () {
                      playMusic();
                    },
                    icon: const Icon(
                      Icons.play_arrow,
                    ),
                    label: const Text(
                      'Putar Lagu',
                    ),
                  ),
                ],
              ),
            ),
          );
        },

        // =====================================================
        // FADETRANSITION
        // =====================================================
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    scaleController.dispose();
    currentSongNotifier.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lirikLagu = LirikLagu(
      judul: 'Happines',
      penyanyi: 'Rex Orange County',
      lirik: 'hm',
    );

    return MaterialApp(
      title: 'Flutter Demo',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(
            255,
            56,
            3,
            149,
          ),
        ),
      ),

      // =====================================================
      // INHERITEDWIDGET
      // =====================================================
      home: MusicPlayerInherited(
        currentSong: currentSongNotifier.value,
        playerActive: playerActive,
        volume: volume,

        child: DefaultTabController(
          length: 2,

          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'My music',
              ),

              bottom: const TabBar(
                tabs: [
                  Tab(
                    icon: Icon(
                      Icons.music_note,
                    ),
                    text: 'Music',
                  ),

                  Tab(
                    icon: Icon(
                      Icons.library_music,
                    ),
                    text: 'Library',
                  ),
                ],
              ),

              actions: [
                Tooltip(
                  message:
                      'Buka menu informasi',

                  child:
                      PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'info') {
                        showMusicInfo();
                      }
                    },

                    itemBuilder:
                        (BuildContext context) {
                      return [
                        const PopupMenuItem(
                          value: 'info',
                          child: Text(
                            'Informasi Lagu',
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              ],
            ),

            // =====================================================
            // DRAWER
            // =====================================================
            drawer: Drawer(
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),

                      Align(
                        alignment:
                            Alignment.center,

                        child: Column(
                          children: [
                            const Icon(
                              Icons.music_note,
                              size: 60,
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            const Text(
                              'My Music',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            const CircleAvatar(
                              radius: 35,
                              backgroundImage:
                                  AssetImage(
                                'assets/happines.png',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      FadeInImage(
                        placeholder:
                            const AssetImage(
                          'assets/happines.png',
                        ),
                        image:
                            const AssetImage(
                          'assets/happines.png',
                        ),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      const Divider(),

                      ElevatedButton(
                        onPressed: () {
                          playMusic();
                        },
                        child: const Text(
                          'Play Music',
                        ),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          );
                        },
                        child: const Text(
                          'Home',
                        ),
                      ),

                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          );
                        },
                        child: const Text(
                          'Playlist',
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      DropdownButton<String>(
                        value: 'Happiness',

                        items: const [
                          DropdownMenuItem(
                            value: 'Happiness',
                            child: Text(
                              'Happiness',
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                                'Loving Is Easy',
                            child: Text(
                              'Loving Is Easy',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Sunflower',
                            child: Text(
                              'Sunflower',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Best Friend',
                            child: Text(
                              'Best Friend',
                            ),
                          ),
                        ],

                        onChanged:
                            (String? value) {},
                      ),

                      const Divider(),

                      // =====================================================
                      // BANNER + FORM
                      // =====================================================
                      Banner(
                        message: 'FORM',
                        location:
                            BannerLocation.topEnd,

                        child: Padding(
                          padding:
                              const EdgeInsets.only(
                            top: 15,
                          ),

                          child: Column(
                            children: [
                              const Text(
                                'Pengaturan Playlist',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(
                                height: 15,
                              ),

                              Form(
                                key: _formKey,

                                child: Column(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal: 20,
                                      ),

                                      child:
                                          TextFormField(
                                        decoration:
                                            const InputDecoration(
                                          labelText:
                                              'Nama Playlist',
                                          border:
                                              OutlineInputBorder(),
                                        ),

                                        validator:
                                            (value) {
                                          if (value ==
                                                  null ||
                                              value
                                                  .isEmpty) {
                                            return 'Masukkan nama playlist';
                                          }

                                          return null;
                                        },
                                      ),
                                    ),

                                    CheckboxListTile(
                                      title:
                                          const Text(
                                        'Happiness',
                                      ),

                                      value:
                                          happinessSelected,

                                      onChanged:
                                          (value) {
                                        setState(() {
                                          happinessSelected =
                                              value!;
                                        });
                                      },
                                    ),

                                    CheckboxListTile(
                                      title:
                                          const Text(
                                        'Loving Is Easy',
                                      ),

                                      value:
                                          lovingIsEasySelected,

                                      onChanged:
                                          (value) {
                                        setState(() {
                                          lovingIsEasySelected =
                                              value!;
                                        });
                                      },
                                    ),

                                    RadioListTile<
                                        String>(
                                      title:
                                          const Text(
                                        'Repeat All',
                                      ),

                                      value:
                                          'Repeat All',

                                      groupValue:
                                          repeatMode,

                                      onChanged:
                                          (value) {
                                        setState(() {
                                          repeatMode =
                                              value!;
                                        });
                                      },
                                    ),

                                    RadioListTile<
                                        String>(
                                      title:
                                          const Text(
                                        'Repeat One',
                                      ),

                                      value:
                                          'Repeat One',

                                      groupValue:
                                          repeatMode,

                                      onChanged:
                                          (value) {
                                        setState(() {
                                          repeatMode =
                                              value!;
                                        });
                                      },
                                    ),

                                    ElevatedButton(
                                      onPressed: () {
                                        if (_formKey
                                            .currentState!
                                            .validate()) {
                                          showPlaylistDialog();
                                        }
                                      },
                                      child:
                                          const Text(
                                        'Simpan Playlist',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      ListTile(
                        leading: const Icon(
                          Icons.info,
                        ),
                        title: const Text(
                          'Informasi Lagu',
                        ),
                        onTap: () {
                          Navigator.pop(
                            context,
                          );

                          showMusicInfo();
                        },
                      ),

                      const Divider(),

                      const Padding(
                        padding:
                            EdgeInsets.all(10),
                        child: Text(
                          'Navigasi',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      NavigationRail(
                        selectedIndex:
                            selectedRailIndex,

                        onDestinationSelected:
                            (index) {
                          setState(() {
                            selectedRailIndex =
                                index;
                          });

                          Navigator.pop(
                            context,
                          );

                          if (index == 0) {
                            print(
                              'Music dipilih',
                            );
                          } else if (index ==
                              1) {
                            print(
                              'Playlist dipilih',
                            );
                          } else if (index ==
                              2) {
                            showMusicInfo();
                          }
                        },

                        labelType:
                            NavigationRailLabelType
                                .all,

                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(
                              Icons.music_note,
                            ),
                            label: Text(
                              'Music',
                            ),
                          ),

                          NavigationRailDestination(
                            icon: Icon(
                              Icons.queue_music,
                            ),
                            label: Text(
                              'Playlist',
                            ),
                          ),

                          NavigationRailDestination(
                            icon: Icon(
                              Icons.info,
                            ),
                            label: Text(
                              'Info',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // =====================================================
            // TABBARVIEW
            // =====================================================
            body: TabBarView(
              children: [
                // =====================================================
                // TAB 1 - MUSIC
                // =====================================================
                Row(
                  children: [
                    // =====================================================
                    // PLAYLIST
                    // =====================================================
                    SizedBox(
                      width: 280,

                      child: Card(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 15,
                            ),

                            const Text(
                              'Your Playlist',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            const Text(
                              'Drag lagu untuk mengubah urutan',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    Colors.grey,
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            Expanded(
                              child: Scrollbar(
                                thumbVisibility:
                                    true,

                                child:
                                    ReorderableListView
                                        .builder(
                                  itemCount:
                                      playlist
                                          .length,

                                  itemBuilder:
                                      (context,
                                          index) {
                                    final lagu =
                                        playlist[
                                            index];

                                    return ListTile(
                                      key: ValueKey(
                                        lagu,
                                      ),

                                      leading:
                                          const Icon(
                                        Icons
                                            .music_note,
                                      ),

                                      title:
                                          Text(
                                        lagu,
                                      ),

                                      trailing:
                                          const Icon(
                                        Icons
                                            .drag_handle,
                                      ),

                                      onTap: () {
                                        openSongPage(
                                          lagu,
                                        );
                                      },
                                    );
                                  },

                                  onReorder: (
                                    oldIndex,
                                    newIndex,
                                  ) {
                                    setState(() {
                                      if (newIndex >
                                          oldIndex) {
                                        newIndex -=
                                            1;
                                      }

                                      final lagu =
                                          playlist
                                              .removeAt(
                                        oldIndex,
                                      );

                                      playlist.insert(
                                        newIndex,
                                        lagu,
                                      );
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // =====================================================
                    // MUSIC PLAYER
                    // =====================================================
                    Expanded(
                      child:
                          SingleChildScrollView(
                        child: Center(
                          child: Container(
                            width: 500,

                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 20,
                            ),

                            child: Column(
                              children: [
                                // =====================================================
                                // TEXTFIELD
                                // =====================================================
                                Padding(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 20,
                                  ),

                                  child: TextField(
                                    decoration:
                                        const InputDecoration(
                                      labelText:
                                          'Cari lagu',
                                      prefixIcon:
                                          Icon(
                                        Icons.search,
                                      ),
                                      border:
                                          OutlineInputBorder(),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 20,
                                ),

                                // =====================================================
                                // INHERITEDWIDGET + VALUELISTENABLEBUILDER
                                // =====================================================
                                ValueListenableBuilder<
                                    String>(
                                  valueListenable:
                                      currentSongNotifier,

                                  builder: (
                                    context,
                                    song,
                                    child,
                                  ) {
                                    final musicData =
                                        MusicPlayerInherited
                                            .of(
                                      context,
                                    );

                                    return Card(
                                      margin:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal:
                                            20,
                                      ),

                                      child:
                                          Padding(
                                        padding:
                                            const EdgeInsets
                                                .all(
                                          12,
                                        ),

                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons
                                                  .info_outline,
                                            ),

                                            const SizedBox(
                                              width: 10,
                                            ),

                                            Expanded(
                                              child:
                                                  Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,

                                                children: [
                                                  const Text(
                                                    'Data dari InheritedWidget',
                                                    style:
                                                        TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),

                                                  Text(
                                                    'Lagu: $song',
                                                  ),

                                                  Text(
                                                    musicData
                                                            .playerActive
                                                        ? 'Status: Aktif'
                                                        : 'Status: Tidak aktif',
                                                  ),

                                                  Text(
                                                    'Volume: ${(musicData.volume * 100).round()}%',
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(
                                  height: 15,
                                ),

                                // =====================================================
                                // ANIMATEDCONTAINER
                                // =====================================================
                                AnimatedContainer(
                                  duration:
                                      const Duration(
                                    milliseconds:
                                        500,
                                  ),

                                  curve:
                                      Curves.easeInOut,

                                  width:
                                      double.infinity,

                                  margin:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 20,
                                  ),

                                  padding:
                                      const EdgeInsets
                                          .all(
                                    15,
                                  ),

                                  decoration:
                                      BoxDecoration(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      playerActive
                                          ? 25
                                          : 15,
                                    ),

                                    color:
                                        playerActive
                                            ? Theme.of(
                                                context,
                                              )
                                                .colorScheme
                                                .primaryContainer
                                            : Theme.of(
                                                context,
                                              )
                                                .colorScheme
                                                .surfaceContainerHighest,

                                    boxShadow:
                                        playerActive
                                            ? [
                                                const BoxShadow(
                                                  blurRadius:
                                                      10,
                                                  spreadRadius:
                                                      2,
                                                  offset:
                                                      Offset(
                                                    0,
                                                    4,
                                                  ),
                                                ),
                                              ]
                                            : [],
                                  ),

                                  child: Row(
                                    children: [
                                      Icon(
                                        playerActive
                                            ? Icons
                                                .music_note
                                            : Icons
                                                .pause_circle_outline,
                                        size: 35,
                                      ),

                                      const SizedBox(
                                        width: 15,
                                      ),

                                      Expanded(
                                        child:
                                            Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,

                                          children: [
                                            const Text(
                                              'Now Playing',
                                              style:
                                                  TextStyle(
                                                fontSize:
                                                    12,
                                              ),
                                            ),

                                            // =====================================================
                                            // ANIMATEDSWITCHER
                                            // =====================================================
                                            ValueListenableBuilder<
                                                String>(
                                              valueListenable:
                                                  currentSongNotifier,

                                              builder:
                                                  (
                                                context,
                                                song,
                                                child,
                                              ) {
                                                return AnimatedSwitcher(
                                                  duration:
                                                      const Duration(
                                                    milliseconds:
                                                        400,
                                                  ),

                                                  transitionBuilder:
                                                      (
                                                    Widget
                                                        child,
                                                    Animation<
                                                            double>
                                                        animation,
                                                  ) {
                                                    return FadeTransition(
                                                      opacity:
                                                          animation,
                                                      child:
                                                          child,
                                                    );
                                                  },

                                                  child:
                                                      Text(
                                                    song,

                                                    key:
                                                        ValueKey(
                                                      song,
                                                    ),

                                                    style:
                                                        const TextStyle(
                                                      fontSize:
                                                          18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),

                                      AnimatedSwitcher(
                                        duration:
                                            const Duration(
                                          milliseconds: 300,
                                        ),

                                        child: Icon(
                                          playerActive
                                              ? Icons
                                                  .play_arrow
                                              : Icons
                                                  .pause,
                                          key: ValueKey(
                                            playerActive,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(
                                  height: 15,
                                ),

                                // =====================================================
                                // ANIMATEDOPACITY
                                // =====================================================
                                AnimatedOpacity(
                                  duration:
                                      const Duration(
                                    milliseconds:
                                        400,
                                  ),

                                  opacity:
                                      showPlayerInfo
                                          ? 1.0
                                          : 0.4,

                                  child: Column(
                                    children: [
                                      if (isLoading)
                                        const CircularProgressIndicator(),

                                      if (isLoading)
                                        const SizedBox(
                                          height: 10,
                                        ),

                                      Text(
                                        isLoading
                                            ? 'Memuat lagu...'
                                            : playerActive
                                                ? 'Lagu sedang diputar'
                                                : 'Lagu sedang di-pause',
                                      ),

                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),

                                // =====================================================
                                // STREAMBUILDER
                                // =====================================================
                                StreamBuilder<String>(
                                  stream:
                                      statusStream,

                                  builder: (
                                    context,
                                    snapshot,
                                  ) {
                                    if (snapshot
                                        .connectionState ==
                                        ConnectionState
                                            .waiting) {
                                      return const Text(
                                        'Menyiapkan status audio...',
                                      );
                                    }

                                    return Container(
                                      margin:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal: 20,
                                      ),

                                      padding:
                                          const EdgeInsets
                                              .all(
                                        10,
                                      ),

                                      decoration:
                                          BoxDecoration(
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          10,
                                        ),

                                        border:
                                            Border.all(
                                          color:
                                              Theme.of(
                                            context,
                                          )
                                                  .colorScheme
                                                  .outline,
                                        ),
                                      ),

                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,

                                        children: [
                                          const Icon(
                                            Icons
                                                .sync,
                                            size: 18,
                                          ),

                                          const SizedBox(
                                            width: 8,
                                          ),

                                          Text(
                                            'StreamBuilder: ${snapshot.data ?? '-'}',
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(
                                  height: 15,
                                ),

                                // =====================================================
                                // FUTUREBUILDER
                                // =====================================================
                                FutureBuilder<Mahasiswa>(
                                  future:
                                      mahasiswaFuture,

                                  builder: (
                                    context,
                                    snapshot,
                                  ) {
                                    if (snapshot
                                            .connectionState ==
                                        ConnectionState
                                            .waiting) {
                                      return const Padding(
                                        padding:
                                            EdgeInsets
                                                .symmetric(
                                          horizontal: 20,
                                        ),

                                        child:
                                            LinearProgressIndicator(),
                                      );
                                    }

                                    if (snapshot.hasError) {
                                      return const Text(
                                        'Gagal memuat data mahasiswa',
                                      );
                                    }

                                    if (!snapshot.hasData) {
                                      return const Text(
                                        'Data mahasiswa tidak tersedia',
                                      );
                                    }

                                    final mahasiswa =
                                        snapshot
                                            .data!;

                                    return Card(
                                      margin:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal: 20,
                                      ),

                                      child:
                                          ListTile(
                                        leading:
                                            const Icon(
                                          Icons
                                              .person,
                                        ),

                                        title:
                                            Text(
                                          'Nama: ${mahasiswa.nama}'
                                        ),

                                        subtitle:
                                            Text(
                                          'Umur: ${mahasiswa.umur}\n'
                                          'Kelas: ${mahasiswa.kelas}',
                                        ),

                                        isThreeLine:
                                            true,
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(
                                  height: 20,
                                ),

                                // =====================================================
                                // PAGEVIEW
                                // =====================================================
                                const Align(
                                  alignment:
                                      Alignment
                                          .centerLeft,

                                  child:
                                      Padding(
                                    padding:
                                        EdgeInsets
                                            .symmetric(
                                      horizontal: 20,
                                    ),

                                    child: Text(
                                      'Now Playing',

                                      style:
                                          TextStyle(
                                        fontSize:
                                            20,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 10,
                                ),

                                SizedBox(
                                  height: 260,

                                  child: PageView(
                                    children: [
                                      // =====================================================
                                      // PAGE 1 - HAPPINESS
                                      // =====================================================
                                      Column(
                                        children: [
                                          // =====================================================
                                          // HERO + SCALETRANSITION
                                          // =====================================================
                                          Hero(
                                            tag:
                                                'cover-happiness',

                                            child:
                                                ScaleTransition(
                                              scale:
                                                  scaleAnimation,

                                              child:
                                                  ClipRRect(
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                  15,
                                                ),

                                                child:
                                                    Image.asset(
                                                  'assets/happines.png',

                                                  width:
                                                      200,
                                                  height:
                                                      200,

                                                  fit: BoxFit
                                                      .cover,
                                                ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(
                                            height: 10,
                                          ),

                                          const Text(
                                            'Happiness',

                                            style:
                                                TextStyle(
                                              fontSize:
                                                  18,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                        ],
                                      ),

                                      // =====================================================
                                      // PAGE 2
                                      // =====================================================
                                      Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                              15,
                                            ),

                                            child:
                                                Image.asset(
                                              'assets/happines.png',

                                              width:
                                                  200,
                                              height:
                                                  200,

                                              fit: BoxFit
                                                  .cover,
                                            ),
                                          ),

                                          const SizedBox(
                                            height: 10,
                                          ),

                                          const Text(
                                            'Loving Is Easy',

                                            style:
                                                TextStyle(
                                              fontSize:
                                                  18,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                        ],
                                      ),

                                      // =====================================================
                                      // PAGE 3
                                      // =====================================================
                                      Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                              15,
                                            ),

                                            child:
                                                Image.asset(
                                              'assets/happines.png',

                                              width:
                                                  200,
                                              height:
                                                  200,

                                              fit: BoxFit
                                                  .cover,
                                            ),
                                          ),

                                          const SizedBox(
                                            height: 10,
                                          ),

                                          const Text(
                                            'Sunflower',

                                            style:
                                                TextStyle(
                                              fontSize:
                                                  18,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                        ],
                                      ),

                                      // =====================================================
                                      // PAGE 4
                                      // =====================================================
                                      Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                              15,
                                            ),

                                            child:
                                                Image.asset(
                                              'assets/happines.png',

                                              width:
                                                  200,
                                              height:
                                                  200,

                                              fit: BoxFit
                                                  .cover,
                                            ),
                                          ),

                                          const SizedBox(
                                            height: 10,
                                          ),

                                          const Text(
                                            'Best Friend',

                                            style:
                                                TextStyle(
                                              fontSize:
                                                  18,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(
                                  height: 15,
                                ),

                                // =====================================================
                                // LIRIK
                                // =====================================================
                                Text(
                                  'Judul: ${lirikLagu.judul}\n'
                                  'Penyanyi: ${lirikLagu.penyanyi}\n\n'
                                  '${lirikLagu.lirik}',

                                  textAlign:
                                      TextAlign.center,

                                  style:
                                      const TextStyle(
                                    fontStyle:
                                        FontStyle
                                            .italic,
                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(
                                  height: 20,
                                ),

                                // =====================================================
                                // WRAP
                                // =====================================================
                                const Align(
                                  alignment:
                                      Alignment
                                          .centerLeft,

                                  child:
                                      Padding(
                                    padding:
                                        EdgeInsets
                                            .symmetric(
                                      horizontal: 20,
                                    ),

                                    child: Text(
                                      'Genre',

                                      style:
                                          TextStyle(
                                        fontSize:
                                            18,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 10,
                                ),

                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment:
                                      WrapAlignment
                                          .center,

                                  children:
                                      const [
                                    Chip(
                                      avatar:
                                          Icon(
                                        Icons
                                            .music_note,
                                      ),
                                      label:
                                          Text(
                                        'Indie',
                                      ),
                                    ),

                                    Chip(
                                      avatar:
                                          Icon(
                                        Icons
                                            .music_note,
                                      ),
                                      label:
                                          Text(
                                        'Pop',
                                      ),
                                    ),

                                    Chip(
                                      avatar:
                                          Icon(
                                        Icons
                                            .headphones,
                                      ),
                                      label:
                                          Text(
                                        'Chill',
                                      ),
                                    ),

                                    Chip(
                                      avatar:
                                          Icon(
                                        Icons
                                            .album,
                                      ),
                                      label:
                                          Text(
                                        'R&B',
                                      ),
                                    ),

                                    Chip(
                                      avatar:
                                          Icon(
                                        Icons
                                            .favorite,
                                      ),
                                      label:
                                          Text(
                                        'Relaxing',
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 25,
                                ),

                                // =====================================================
                                // GRIDVIEW
                                // =====================================================
                                const Align(
                                  alignment:
                                      Alignment
                                          .centerLeft,

                                  child:
                                      Padding(
                                    padding:
                                        EdgeInsets
                                            .symmetric(
                                      horizontal: 20,
                                    ),

                                    child: Text(
                                      'Recommended Songs',

                                      style:
                                          TextStyle(
                                        fontSize:
                                            20,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 10,
                                ),

                                GridView.count(
                                  crossAxisCount:
                                      2,

                                  crossAxisSpacing:
                                      10,

                                  mainAxisSpacing:
                                      10,

                                  shrinkWrap:
                                      true,

                                  physics:
                                      const NeverScrollableScrollPhysics(),

                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 20,
                                  ),

                                  children: [
                                    _buildSongCard(
                                      'Happiness',
                                      Icons
                                          .music_note,
                                    ),

                                    _buildSongCard(
                                      'Loving Is Easy',
                                      Icons
                                          .favorite,
                                    ),

                                    _buildSongCard(
                                      'Sunflower',
                                      Icons
                                          .wb_sunny,
                                    ),

                                    _buildSongCard(
                                      'Best Friend',
                                      Icons.people,
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 25,
                                ),

                                // =====================================================
                                // CUSTOMSCROLLVIEW
                                // =====================================================
                                const Align(
                                  alignment:
                                      Alignment
                                          .centerLeft,

                                  child:
                                      Padding(
                                    padding:
                                        EdgeInsets
                                            .symmetric(
                                      horizontal: 20,
                                    ),

                                    child: Text(
                                      'Music Information',

                                      style:
                                          TextStyle(
                                        fontSize:
                                            20,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 10,
                                ),

                                SizedBox(
                                  height: 180,

                                  child:
                                      CustomScrollView(
                                    shrinkWrap:
                                        true,

                                    physics:
                                        const NeverScrollableScrollPhysics(),

                                    slivers: [
                                      SliverToBoxAdapter(
                                        child: Card(
                                          child:
                                              Padding(
                                            padding:
                                                const EdgeInsets
                                                    .all(
                                              16,
                                            ),

                                            child:
                                                Column(
                                              children:
                                                  const [
                                                ListTile(
                                                  leading:
                                                      Icon(
                                                    Icons
                                                        .album,
                                                  ),
                                                  title:
                                                      Text(
                                                    'Album',
                                                  ),
                                                  subtitle:
                                                      Text(
                                                    'Rex Orange County',
                                                  ),
                                                ),

                                                Divider(),

                                                ListTile(
                                                  leading:
                                                      Icon(
                                                    Icons
                                                        .music_note,
                                                  ),
                                                  title:
                                                      Text(
                                                    'Current Playlist',
                                                  ),
                                                  subtitle:
                                                      Text(
                                                    'My Favorite Songs',
                                                  ),
                                                ),

                                                Divider(),

                                                ListTile(
                                                  leading:
                                                      Icon(
                                                    Icons
                                                        .volume_up,
                                                  ),
                                                  title:
                                                      Text(
                                                    'Audio',
                                                  ),
                                                  subtitle:
                                                      Text(
                                                    'Music Player',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(
                                  height: 20,
                                ),

                                // =====================================================
                                // LINEAR PROGRESS INDICATOR
                                // =====================================================
                                const Align(
                                  alignment:
                                      Alignment
                                          .centerLeft,

                                  child:
                                      Padding(
                                    padding:
                                        EdgeInsets
                                            .symmetric(
                                      horizontal: 20,
                                    ),

                                    child: Text(
                                      'Progress Lagu',

                                      style:
                                          TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 8,
                                ),

                                const Padding(
                                  padding:
                                      EdgeInsets
                                          .symmetric(
                                    horizontal: 20,
                                  ),

                                  child:
                                      LinearProgressIndicator(
                                    value: 0.45,
                                  ),
                                ),

                                const SizedBox(
                                  height: 20,
                                ),

                                // =====================================================
                                // SWITCH
                                // =====================================================
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,

                                  children: [
                                    const Text(
                                      'Shuffle',
                                    ),

                                    Switch(
                                      value:
                                          shuffle,

                                      onChanged:
                                          (value) {
                                        setState(
                                          () {
                                            shuffle =
                                                value;
                                          },
                                        );

                                        ScaffoldMessenger
                                                .of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content:
                                                Text(
                                              value
                                                  ? 'Shuffle aktif'
                                                  : 'Shuffle nonaktif',
                                            ),
                                            duration:
                                                const Duration(
                                              seconds:
                                                  1,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),

                                // =====================================================
                                // SLIDER
                                // =====================================================
                                Slider(
                                  value: volume,

                                  min: 0,
                                  max: 1,

                                  divisions: 10,

                                  label:
                                      volume
                                          .toString(),

                                  onChanged:
                                      (value) {
                                    setState(() {
                                      volume =
                                          value;
                                    });

                                    player
                                        .setVolume(
                                      value,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // =====================================================
                // TAB 2 - LIBRARY
                // =====================================================
                Center(
                  child:
                      SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                      children: [
                        const Icon(
                          Icons.library_music,
                          size: 100,
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        const Text(
                          'Music Library',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        const Text(
                          'Koleksi lagu yang tersedia',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        ...playlist.map(
                          (lagu) {
                            return SizedBox(
                              width: 400,

                              child: Card(
                                child:
                                    ListTile(
                                  leading:
                                      const Icon(
                                    Icons
                                        .music_note,
                                  ),

                                  title:
                                      Text(
                                    lagu,
                                  ),

                                  trailing:
                                      const Icon(
                                    Icons
                                        .arrow_forward_ios,
                                  ),

                                  onTap: () {
                                    openSongPage(
                                      lagu,
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // =====================================================
            // FLOATING ACTION BUTTON
            // SCALETRANSITION
            // =====================================================
            floatingActionButton:
                ScaleTransition(
              scale: scaleAnimation,

              child: Tooltip(
                message:
                    'Putar lagu Happiness',

                child:
                    FloatingActionButton(
                  onPressed: () async {
                    // Animasi tekan tombol
                    await scaleController
                        .forward();

                    // Putar lagu SATU KALI
                    await playMusic();

                    // Kembalikan ukuran tombol
                    await scaleController
                        .reverse();
                  },

                  child: const Icon(
                    Icons.play_arrow,
                  ),
                ),
              ),
            ),

            // =====================================================
            // BOTTOM NAVIGATION BAR
            // =====================================================
            bottomNavigationBar:
                BottomNavigationBar(
              currentIndex:
                  selectedBottomIndex,

              onTap: (index) {
                setState(() {
                  selectedBottomIndex =
                      index;
                });

                if (index == 0) {
                  playMusic();
                } else if (index == 1) {
                  pauseMusic();
                } else if (index == 2) {
                  showMusicInfo();
                }
              },

              items: const [
                BottomNavigationBarItem(
                  icon: Tooltip(
                    message:
                        'Putar lagu',

                    child: Icon(
                      Icons.play_arrow,
                    ),
                  ),
                  label: 'Play',
                ),

                BottomNavigationBarItem(
                  icon: Tooltip(
                    message:
                        'Pause lagu',

                    child: Icon(
                      Icons.pause,
                    ),
                  ),
                  label: 'Pause',
                ),

                BottomNavigationBarItem(
                  icon: Tooltip(
                    message:
                        'Informasi lagu',

                    child: Icon(
                      Icons.info,
                    ),
                  ),
                  label: 'Info',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // FUNCTION UNTUK GRIDVIEW
  // =====================================================
  Widget _buildSongCard(
    String title,
    IconData icon,
  ) {
    return Card(
      elevation: 3,

      child: InkWell(
        onTap: () {
          if (mounted) {
            setState(() {
              showPlayerInfo = true;
            });
          }

          currentSongNotifier.value =
              title;

          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                '$title dipilih',
              ),
              duration:
                  const Duration(seconds: 1),
            ),
          );

          openSongPage(title);
        },

        child: Padding(
          padding:
              const EdgeInsets.all(10),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              Icon(
                icon,
                size: 45,
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                title,
                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}